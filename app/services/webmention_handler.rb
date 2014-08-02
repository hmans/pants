class WebmentionHandler
  include Backgroundable

  attr_reader :site, :source, :target, :response

  def initialize(site, source, target)
    @site = site
    @source = source
    @target = target
  end

  def handle!
    # Basic sanity checks.
    return false if source.blank?
    return false if target.blank?
    return false if site.blank?
    return false unless URI.parse(target).host == site.domain

    # fetch the document
    @response = HTTParty.get(source)

    if post = fetch_post
      # check if post actually contains a link to the target (or references it).
      return false unless post.referenced_url == target || Nokogiri::HTML(post.body_html).css("a[href=\"#{target}\"]").any?

      # Add the post to this user's timeline.
      site.add_to_timeline(post)
    elsif user = fetch_user
      # TODO: track as follower
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
