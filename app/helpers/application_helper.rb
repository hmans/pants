module ApplicationHelper
  def avatar(user)
    link_to(image_tag(user.external_image_url), user.url, class: 'avatar')
  end

  def navigation_entry(title, url, opts = {})
    active = (opts[:controller].present? && opts[:controller] == controller.controller_name) ||
      current_page?(url)

    content_tag(:li, class: (active ? 'active' : nil)) do
      link_to(title, url, opts)
    end
  end
end
