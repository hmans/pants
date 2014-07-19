# `PostFetcher` will fetch a post from a remote URL and store it in the local
# database.
#
# In theory, it could refuse to do its job for post URLs that look like they
# live on the current instance; however, we must take the situation into account
# that a user moves their site to a new instance without having their `User#hosted`
# reset to false in the old instance (ie. the user is now remote, without this
# instance knowing it.)
#
# In addition to fetching the post, `PostFetcher` will add the post to the timelines
# of local followers of the post's author.
#
class PostFetcher
  include Backgroundable

  class InvalidData < RuntimeError ; end

  def initialize(url, opts = {})
    @url = expand_url(url)
    @opts = opts
    @uri = URI.parse(@url)
  end

  def fetch!
    Rails.logger.info "Fetching post: #{@url}"

    # TODO: determine if we should _really_ fetch the post, as it may not
    #       always be necessary.

    @json = fetch_json

    if @json.not_found?
      Rails.logger.info "No post found at #{@url}"
      # The post was not found -- if we already have a post with the given
      # URL, we need to delete it.
      #
      if @post = Post[@url]
        Rails.logger.info "Deleting existing post found for #{@url}"
        @post.destroy
      end
    else
      # The post was found, so let's fetch its author's data and upsert it!
      #
      Post.transaction do
        # Fetch associated user
        UserFetcher.fetch!(@uri.host)

        # Upsert post in database
        @post = PostUpserter.upsert!(@json, @url)

        # Push post to local timelines
        PostPusher.new(@post).push_to_local_timelines

        # If a recipient was specified, add this post to their timeline
        if @opts[:recipient].present?
          @opts[:recipient].add_to_timeline(@post)
        end

        # Done! Return the post.
        @post
      end
    end

    # If we have a post now and it's referencing another post, give that post a chance
    # to update its like/reply counts.
    if op = @post.try(:reference)
      op.save!
    end

    # Done. Return wherever post is at now.
    @post
  end

  def expand_url(url)
    url.with_http
  end

  def fetch_json
    response = HTTParty.get(@url)

    case response.content_type
    when 'application/json'
      return response
    when 'text/html'
      if json_url = discover_json_url(response.body)
        Rails.logger.info "Discovered JSON URL #{json_url} for #{@url}"
        return HTTParty.get(json_url)
      else
        # try appending .json as a fallback; mostly to remain compatible
        # with earlier versions of pants.
        Rails.logger.info "Trying #{@url}.json as a fallback"
        return HTTParty.get("#{@url}.json")
      end
    else
      raise "Invalid content type #{response.content_type} for post #{@url}"
    end
  end

  def discover_json_url(html)
    if doc = Nokogiri::HTML(html)
      if link_tag = doc.css('link[rel="alternate"][type="application/json"]').first
        link_tag[:href]
      end
    end
  end

  class << self
    def fetch!(*args)
      new(*args).fetch!
    end
  end
end
