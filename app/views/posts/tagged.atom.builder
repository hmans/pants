atom_feed :language => current_site.locale do |feed|
  feed.title "#{current_site.display_name} - #{@all ? 'All posts tagged:' : 'Posts tagged:'} #{@tags.to_sentence}"

  posts = @posts.limit(20)
  feed.updated posts.maximum(:edited_at)
  render posts, feed: feed
end
