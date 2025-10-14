module ApplicationHelper
  def auth_page?
    (controller_name == "sessions" && %w[new create].include?(action_name)) ||
      (controller_name == "users" && %w[new create].include?(action_name))
  end

  def nav_link_to(name, path, **options)
    active_class = current_page?(path) ? "active" : ""
    class_attr = [ options[:class], active_class ].compact.join(" ")
    link_to name, path, **options.merge(class: class_attr)
  end
end
