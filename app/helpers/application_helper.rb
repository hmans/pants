module ApplicationHelper
  def avatar(user, opts = {})
    opts = {
      class: 'avatar'
    }.merge(opts)

    link_to(user.url, opts) do
      image_tag(user.local_thumbnail.present? ? user.local_thumbnail.url : '1x1.png')
    end
  end

  def navigation_entry(title, url, opts = {})
    active = (opts[:controller].present? && opts[:controller] == controller.controller_name) ||
      current_page?(url)

    content_tag(:li, class: (active ? 'active' : nil)) do
      link_to(title, url, opts)
    end
  end
end
