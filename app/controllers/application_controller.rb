class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :require_login

  private

  def create_session_for(user)
    reset_session # prevent session fixation
    session[:user_id] = user.id
    session[:expires_at] = 1.week.from_now
  end

  def current_user
    if session[:user_id] && session[:expires_at] && Time.current <= session[:expires_at]
      @current_user ||= User.find_by(id: session[:user_id])
    else
      reset_session
      nil
    end
  end

  helper_method :current_user

  def current_user?(user)
    current_user == user
  end

  def require_login
    unless current_user
      session[:intended_url] = request.url
      redirect_to login_url, alert: "You must be logged in to access this page"
    end
  end

  def logged_in?
    current_user.present?
  end

  def redirect_if_logged_in
    if logged_in?
      redirect_to profile_path, notice: "You are already logged in"
    end
  end
end
