class WebmentionHandler
  include Backgroundable

  attr_reader :site, :source, :target, :response

  def initialize(site, source, target)
    @site = site
    @source = source
    @target = target
  end

  def handle!
    # fetch the document
    @response = HTTParty.get(source)

    # check if target is site's domain.
    return false unless URI.parse(target).host == site.domain

    if post = fetch_post
      # check if post actually contains a link to the target.
      return false unless Nokogiri::HTML(post.body_html).css("a[href=\"#{target}\"]").any?

      # Add the post to this user's timeline.
      site.add_to_timeline(post)
    elsif user = fetch_user
      # track as follower
    end
  end

private

  def fetch_post
    PostFetcher.fetch!(source, response: response)
  end

  def fetch_user
    # Coming soon...
  end

  class << self
    def handle!(*args)
      new(*args).handle!
    end
  end
end
