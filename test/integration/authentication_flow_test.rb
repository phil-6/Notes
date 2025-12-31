require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
  end

  test "user can sign up with valid information" do
    get sign_up_url
    assert_response :success

    assert_difference("User.count") do
      post sign_up_url, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          display_name: "New User"
        }
      }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
  end

  test "user can sign in and sign out" do
    get sign_in_url
    assert_response :success

    post sign_in_url, params: { email: @user.email, password: "password123" }
    assert_redirected_to root_url

    follow_redirect!
    assert_response :success

    delete sign_out_url
    assert_redirected_to sign_in_url

    follow_redirect!
    assert_response :success
  end

  test "user cannot access protected pages when not signed in" do
    get root_url
    assert_redirected_to sign_in_url

    get notes_url
    assert_redirected_to sign_in_url

    get connections_url
    assert_redirected_to sign_in_url
  end

  test "user can access protected pages when signed in" do
    sign_in_as(@user)

    get root_url
    assert_response :success

    get connections_url
    assert_response :success
  end
end
