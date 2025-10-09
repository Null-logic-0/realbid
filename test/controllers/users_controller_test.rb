require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @existing_user = users(:one)
  end

  test "should get new" do
    get new_user_path
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      post users_path, params: { user: {
        name: "New User",
        email: "newuser@example.com",
        password: "password1234",
        password_confirmation: "password1234"
      } }
    end

    new_user = User.find_by(email: "newuser@example.com")
    assert_redirected_to user_path(new_user)
  end
end
