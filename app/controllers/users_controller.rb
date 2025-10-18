class UsersController < ApplicationController
  before_action :require_login, except: [ :new, :create ]
  before_action :set_user, only: [ :show ]
  before_action :redirect_if_logged_in, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def show; end

  def profile
    @user = current_user
    render :show
  end

  def create
    @user = User.new(user_params.except(:phone_number))
    if @user.save
      create_session_for(@user)
      redirect_to profile_path, notice: "You have successfully signed up!"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render "new", status: :unprocessable_entity
    end
  end

  def update_password
    @user = current_user
    if @user.authenticate(password_params[:current_password])
      if @user.update(password_params.slice(:password, :password_confirmation))
        reset_session
        redirect_to login_path, notice: "You have successfully updated your password!"
      else
        flash.now[:alert] = "Failed to update your password."
        render :show, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Current password is incorrect!"
      render :show, status: :unprocessable_entity
    end
  end

  def update_profile
    @user = current_user
    if @user.update(user_params.except(:current_password, :password, :password_confirmation).reject { |_, v| v.blank? })
      redirect_to profile_path, notice: "You have successfully updated your profile!"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  def update_info
    @user = current_user
    if @user.update(info_params.except(:current_password, :password, :password_confirmation, :email, :name, :profile_image).reject { |_, v| v.blank? })
      redirect_to profile_path, notice: "You have successfully updated your info!"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  def delete_account
    @user = current_user
    if @user.destroy
      reset_session
      redirect_to signup_url, alert: "Account has been deleted."
    else
      flash[:alert] = "You can only delete your own account!"
      render :show, status: :unprocessable_entity
    end
  end

  private

  def info_params
    params.require(:user).permit(:country, :city, :address, :postal_code, :phone_number)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation, :profile_image)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
