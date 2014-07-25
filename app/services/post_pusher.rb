# PostPusher accepts a post and pushes it to anyone who may be
# interested, including:
#
# - the author's local & remote friends
# - the author's local followers
#
class PostPusher
  include Backgroundable

  def initialize(post)
    @post = post
  end

  def push!
    Rails.logger.info "Pushing post #{@post.url}..."

    push_to_local_timelines

    # send webmentions for referenced links
    extract_referenced_links.each do |link|
      Webmentioner.new(@post.url, link).send!
    end
  end

  def push_to_local_timelines
    if @post.user.present?
      @post.user.followers.hosted.find_each do |follower|
        follower.add_to_timeline(@post)
      end
    end
  end

  def ping_friends
    if @post.user.present?
      @post.user.friends.find_each do |friend|
        Webmentioner.new(@post.url, friend.url).send!
      end
    end
  end

private

  def extract_referenced_links
    # extract links from body
    doc = Nokogiri::HTML.parse(@post.body_html)
    links = doc.css('a').map { |link| link[:href] }

    # add referenced guid
    links << @post.referenced_guid.with_http if @post.referenced_guid.present?

    # remove empty/duplicate elements
    links.compact.uniq
  end
end
