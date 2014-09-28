# PostPusher accepts a post and pushes it to anyone who may be
# interested, including:
#
# - the author's local & remote friends
# - the author's local followers
#
class PostPusher < Service
  def perform(post)
    @post = post

    logger.info "Pushing post #{@post.url}..."

    push_to_local_timelines unless @post.destroyed?

    # send webmentions for referenced links
    urls = extract_referenced_links
    if urls.any?
      logger.info "Sending webmentions to the following URLs: #{urls.to_sentence}"
      urls.each do |url|
        Webmentioner.perform(@post.url, url)
      end
    end
  end

  def push_to_local_timelines
    if @post.user.present?
      @post.user.followers.hosted.find_each do |follower|
        follower.add_to_timeline(@post)
      end
    end
  end

private

  def extract_referenced_links
    # extract links from body
    doc = Nokogiri::HTML.parse(@post.body_html)
    links = doc.css('a').map { |link| link[:href] }

    # add referenced guid
    links << @post.referenced_url if @post.referenced_url.present?

    # remove empty/duplicate elements
    links.compact.uniq
  end
end
