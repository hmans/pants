feed.entry(post, id: "tag:#{post.domain},2005:#{post.slug}") do |entry|
  entry.url     post.url
  entry.title   post.title

  # content
  entry.content render(partial: 'post_for_feed', locals: { post: post }, formats: ['html']), type: 'html'

  # author
  entry.author do |author|
    author.name post.user.display_name
    author.uri post.user.url
  end
end
