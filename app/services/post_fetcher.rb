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

  attr_reader :url, :opts, :response

  class InvalidData < RuntimeError ; end

  def initialize(url, opts = {})
    @url = url.with_http
    @opts = opts
    @response = opts[:response]
  end

  def fetch!
    Rails.logger.info "Fetching post: #{@url}"

    # Upsert the post's user
    UserFetcher.fetch!(URI.parse(url).host)

    # Try loading the post
    @response ||= HTTParty.get(url)
    @post = check_for_4xx || check_for_linked_json || import_json # || import_mf2

    # If the post we have now is referencing another post, give that post a chance
    # to update its like/reply counts.
    if op = @post.try(:reference)
      op.save!
    end

    # Done. Return wherever post is at now.
    @post
  end

  def check_for_4xx
    if response.not_found?
      Rails.logger.info "No post found at #{@url}"

      if post = Post[url]
        Rails.logger.info "Deleting existing post found for #{@url}"

        post.destroy
        post
      end
    end
  end

  def check_for_linked_json
    if response.content_type == 'text/html'
      document = Nokogiri::HTML(@response.body)

      if link_tag = document.css('link[rel="alternate"][type="application/json"]').first
        # Overwrite response with fetched JSON
        @response = HTTParty.get(link_tag[:href])

        # Return false to continue processing
        false
      end
    end
  end

  def import_json
    # If the response is JSON, assume it's a #pants post and import it.
    if response.content_type == 'application/json'
      PostUpserter.upsert!(response.to_hash, url)
    end
  end

  def import_mf2
    if mf2 = Microformats2.parse(response.body)
      if mf2.entry.present?
        # build #pants data structure
        data = {
          'type' => 'pants.post',
          'guid' => url.to_guid,
          'url' => url,
          'published_at' => (mf2.entry.published.to_s if mf2.entry.respond_to?(:published)),
          'edited_at' => (mf2.entry.updated.to_s if mf2.entry.respond_to?(:updated)),
          'referenced_guid' => nil,
          'referenced_url' => nil, # FIXME
          'title' => (mf2.entry.name.to_s if mf2.entry.respond_to?(:name)),
          'body_html' => mf2.entry.content.to_s
        }

        PostUpserter.upsert!(data, url)
      end
    end
  end

  class << self
    def fetch!(*args)
      new(*args).fetch!
    end
  end
end
