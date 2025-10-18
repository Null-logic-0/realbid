require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should render 404 not found" do
    get "/404"
    assert_response :not_found
  end

  test "should render 500 internal server error" do
    get "/500"
    assert_response :internal_server_error
  end
end
