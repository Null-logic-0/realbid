class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Handle record not found globally
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  # Handle other errors
  rescue_from StandardError, with: :render_internal_error unless Rails.env.development?

  before_action :require_login

  private

  def create_session_for(user)
    reset_session
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

  # Errors

  def render_not_found(exception = nil)
    logger.info "Not Found: #{exception.message}" if exception
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
    end
  end

  def render_internal_error(exception = nil)
    logger.error exception.message if exception
    logger.error exception.backtrace.join("\n") if exception
    respond_to do |format|
      format.html { render "errors/internal_server_error", status: :internal_server_error }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end
end
