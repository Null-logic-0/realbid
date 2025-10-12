require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @password = "password1234"
  end

  # GET /login
  test "should get login page" do
    get login_path
    assert_response :success
  end

  # POST /session - successful login
  test "should log in with valid credentials" do
    log_in_as(@user)
    assert_redirected_to profile_path
    follow_redirect!
    assert_response :success
    assert_equal @user.id, session[:user_id]
  end

  # POST /session - invalid login
  test "should not log in with invalid credentials" do
    post session_path, params: { user: { email: @user.email, password: "wrongpassword" } }
    assert_redirected_to login_path
    follow_redirect!
    assert_nil session[:user_id]
    assert_response :success
  end

  # DELETE /session - logout
  test "should log out user" do
    log_in_as(@user)
    assert_equal @user.id, session[:user_id]
    delete session_path
    assert_redirected_to login_path
    follow_redirect!
    assert_nil session[:user_id]
    assert_response :success
  end

  def log_in_as(user)
    post session_path, params: { user: { email: user.email, password: @password } }
  end
end
