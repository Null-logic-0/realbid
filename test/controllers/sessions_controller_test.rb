require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  # GET /login
  test "should get login page" do
    get login_path
    assert_response :success
  end

  # POST /session - successful login
  test "should log in with valid credentials" do
    post session_path, params: { user: { email: @user.email, password: "password1234" } }
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_response :success
    assert_equal @user.id, session[:user_id]
  end

  # POST /session - invalid login
  test "should not log in with invalid credentials" do
    post session_path, params: { user: { email: @user.email, password: "wrongpass12344" } }
    assert_response :unauthorized
    assert_nil session[:user_id]
  end

  # DELETE /session - logout
  test "should log out user" do
    # First log in
    post session_path, params: { user: { email: @user.email, password: "password1234" } }
    assert_equal @user.id, session[:user_id]

    # Then log out
    delete session_path
    assert_redirected_to login_path
    follow_redirect!
    assert_nil session[:user_id]
    assert_response :success
  end
end
