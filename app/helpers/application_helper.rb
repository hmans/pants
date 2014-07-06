module ApplicationHelper
  def avatar(user, opts = {})
    opts = {
      class: 'avatar'
    }.merge(opts)

    link_to(user.url, opts) do
      if user.local_thumbnail.present?
        image_tag(user.local_thumbnail.url)
      end
    end
  end

  def navigation_entry(title, url, opts = {})
    active = (opts[:controller].present? && opts[:controller] == controller.controller_name) ||
      current_page?(url)

    content_tag(:li, class: (active ? 'active' : nil)) do
      link_to(title, url, opts)
    end
  end

  def day_path(opts = {})
    if date = opts.delete(:date)
      opts = opts.merge(
        year:  sprintf('%04d', date.year),
        month: sprintf('%02d', date.month),
        day:   sprintf('%02d', date.day)
      )
    end
    super(opts)
  end
end
