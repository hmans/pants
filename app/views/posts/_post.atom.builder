feed.entry(post, id: "tag:#{post.domain},2005:#{post.slug}") do |entry|
  entry.url     post.url
  entry.title   post.title

  # content
  entry.content post.body_html, type: 'html'

  # author
  entry.author do |author|
    author.name post.user.display_name
    author.uri post.user.url
  end
end
