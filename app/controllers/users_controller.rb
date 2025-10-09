class UsersController < ApplicationController
  before_action :require_login, except: [ :new, :create ]

  def new
    @user = User.new
  end

  def show
    set_user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      create_session_for(@user)
      redirect_to user_path(@user)
    else
      render "new", status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
