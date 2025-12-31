require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
  end

  test "should get new" do
    get sign_in_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    post sign_in_url, params: { email: @user.email, password: "password123" }
    assert_redirected_to root_url
    assert session[:user_id].present?
  end

  test "should not create session with invalid email" do
    post sign_in_url, params: { email: "wrong@example.com", password: "password123" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should not create session with invalid password" do
    post sign_in_url, params: { email: @user.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should destroy session" do
    post sign_in_url, params: { email: @user.email, password: "password123" }
    assert session[:user_id].present?

    delete sign_out_url
    assert_redirected_to sign_in_url
    assert_nil session[:user_id]
  end
end
