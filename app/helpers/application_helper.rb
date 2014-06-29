module ApplicationHelper
  def avatar(user)
    link_to(image_tag(user.external_image_url), user.url, class: 'avatar')
  end
end
