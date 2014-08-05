json.pants do
  json.user do
    json.url current_site.url
    json.display_name current_site.display_name
    json.image URI.join(current_site.url, '/user.jpg').to_s
    json.counts do
      json.posts current_site.posts.count
      json.following current_site.friends.count
    end
  end
  json.endpoints do
    json.login login_url(format: 'json')
    json.posts posts_url(format: 'json')
    json.timeline network_url(format: 'json')
    json.webmention ping_url
  end
end
