require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @password = "password1234"
    @user.update!(password: @password, password_confirmation: @password)
  end

  # --GET /signup
  test "should get new (signup) page" do
    get signup_path
    assert_response :success
    assert_select "form"
  end

  # --- POST /users ---
  test "should create user with valid params" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          name: "New User",
          email: "new@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        }
      }
    end
    assert_redirected_to profile_path
    follow_redirect!
    assert_match "successfully signed up", response.body
  end

  test "should not create user with invalid params" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          email: "",
          password: "123",
          password_confirmation: "456"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # --- GET /profile ---
  test "should show current_user profile" do
    log_in_as(@user)
    get profile_path
    assert_response :success
    assert_select "h1", text: @user.name
  end

  test "should redirect profile when not logged in" do
    get profile_path
    assert_redirected_to login_path
  end

  # --- PATCH /update_password ---
  test "should update password with valid current password" do
    log_in_as(@user)
    patch update_password_path, params: {
      user: {
        current_password: "password1234",
        password: "password12345",
        password_confirmation: "password12345"
      }
    }
    assert_redirected_to login_path
    assert_match /successfully updated your password/i, flash[:notice]
  end

  test "should not update password with invalid current password" do
    log_in_as(@user)
    patch update_password_path, params: {
      user: {
        current_password: "wrong12345678",
        password: "pass12345678",
        password_confirmation: "pass12345678"
      }
    }
    assert_response :unprocessable_entity
    assert_match "Current password is incorrect", response.body
  end

  # --- PATCH /update_profile ---
  test "should update profile with valid data" do
    log_in_as(@user)
    patch update_profile_path, params: {
      user: { name: "UPDATED NAME" }
    }
    assert_redirected_to profile_path
    @user.reload
    assert_equal "UPDATED NAME", @user.name
  end

  # --- DELETE /delete_account ---
  test "should delete account" do
    log_in_as(@user)

    assert_difference("User.count", -1) do
      delete delete_account_path
    end

    assert_redirected_to signup_path
    follow_redirect!
  end

  # --- PATCH /update_info ---
  test "should update info with valid params" do
    log_in_as(@user)
    patch update_info_path, params: {
      user: {
        country: "Georgia",
        city: "Tbilisi",
        address: "Freedom Square 1",
        postal_code: "0105",
        phone_number: "1234567890"
      }
    }

    assert_redirected_to profile_path
    follow_redirect!
    assert_match "You have successfully updated your info!", flash[:notice]

    @user.reload
    assert_equal "Georgia", @user.country
    assert_equal "Tbilisi", @user.city
  end

  private

  def log_in_as(user)
    post session_path, params: { user: { email: user.email, password: @password } }
    follow_redirect! if response.redirect?
  end
end
