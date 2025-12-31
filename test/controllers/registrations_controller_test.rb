require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sign_up_url
    assert_response :success
  end

  test "should create user with valid params" do
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
    assert session[:user_id].present?
  end

  test "should not create user with invalid email" do
    assert_no_difference("User.count") do
      post sign_up_url, params: {
        user: {
          email: "invalid",
          password: "password123",
          password_confirmation: "password123",
          display_name: "New User"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with mismatched passwords" do
    assert_no_difference("User.count") do
      post sign_up_url, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "different",
          display_name: "New User"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with duplicate email" do
    existing_user = users(:alice)

    assert_no_difference("User.count") do
      post sign_up_url, params: {
        user: {
          email: existing_user.email,
          password: "password123",
          password_confirmation: "password123",
          display_name: "New User"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
