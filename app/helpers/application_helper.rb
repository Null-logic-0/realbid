module ApplicationHelper
  def nav_link_to(name, path, **options)
    active_class = current_page?(path) ? "active" : ""
    class_attr = [ options[:class], active_class ].compact.join(" ")
    link_to name, path, **options.merge(class: class_attr)
  end
end
