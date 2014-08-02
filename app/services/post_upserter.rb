# This service class receives JSON for a single post together with
# the JSON's source URL and updates inserts a post using this data
# after performing some sanity checks.
#
class PostUpserter < Service
  # The following attributes will be copied from post JSON responses
  # into local Post instances.
  #
  ACCESSIBLE_JSON_ATTRIBUTES = %w{
    type
    guid
    url
    published_at
    edited_at
    referenced_guid
    referenced_url
    title
    body
    body_html
    data
    tags
    number_of_replies
  }

  class InvalidData < RuntimeError ; end

  attr_accessor :json, :source_url

  def perform(json, source_url)
    @json = json
    @source_url = source_url

    if json_sane?
      Post.transaction do
        post = Post.where(guid: json['guid']).first_or_initialize

        if post.new_record? || post.edited_at < json['edited_at']
          # Transfer whitelisted attributes
          post.attributes = json.slice(*ACCESSIBLE_JSON_ATTRIBUTES)

          # Extract #domain and #slug from #url
          post.domain = @post_uri.host
          post.slug   = @post_uri.path.sub(/^\//, '')

          post.save!
        end

        post
      end
    end
  end

  def source_uri
    @source_uri ||= URI.parse(source_url)
  end

  def post_uri
    @post_uri ||= URI.parse(@json['url'])
  end

  def json_sane?
    # We're okay with the JSON as long as the referenced post URL matches the
    # host we got the JSON from.
    #
    if post_uri.host != source_uri.host
      raise InvalidData, "#{post_uri.host} doesn't match expected host #{source_uri.host} (#{source_url})"
    end

    # Actually, let's check the provided GUID anyway. For now, we're happy if it, too,
    # uses the same host as the source URL.
    guid_host = json['guid'].split('/').first
    if guid_host != source_uri.host
      raise InvalidData, "#{json['guid']} doesn't match expected host #{source_uri.host} (#{source_url})"
    end

    true
  end
end
