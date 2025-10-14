module UsersHelper
  def profile_image(user)
    if user.profile_image.attached? && user.persisted? && user.errors[:profile_image].blank?
      image_tag url_for(user.profile_image)
    else
      image_tag "default.jpg"
    end
  end
end
