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
  include BackgroundJob

  def perform(url, opts = {})
    with_appsignal do
      Rails.logger.info "Fetching post: #{url}"
      url = expand_url(url)
      json = fetch_json(url)

      if json_sane?(json, url)
        # fetch/update user first
        UserFetcher.perform(URI.parse(url).host)

        # deal with post
        post = upsert_post(json)
        add_to_local_timelines(post)

        if opts[:recipient].present?
          opts[:recipient].add_to_timeline(post)
        end

        post
      end
    end
  end

  def expand_url(url)
    url = url.with_http
    url.ends_with?(".json") ? url : "#{url}.json"
  end

  def fetch_json(url)
    HTTParty.get(url)
  end

  def json_sane?(json, url)
    full, guid, domain, slug = %r{^https?://((.+)/(.+?))(\.json)?$}.match(url).to_a

    raise "Post JSON invalid: guid doesn't match" if json['guid'] != guid
    raise "Post JSON invalid: domain doesn't match" if json['domain'] != domain
    raise "Post JSON invalid: slug doesn't match" if json['slug'] != slug

    true
  end

  def upsert_post(json)
    with_database do
      Post.from_json!(json)
    end
  end

  def add_to_local_timelines(post)
    TimelineManager.new.add_post_to_local_timelines(post)
  end
end
