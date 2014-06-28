atom_feed :language => current_site.locale do |feed|
  feed.title current_site.display_name

  posts = @posts.limit(20)
  feed.updated posts.maximum(:edited_at)
  render posts, feed: feed
end
