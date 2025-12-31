require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
  end

  test "user signs up successfully" do
    visit sign_up_url

    fill_in "Email", with: "newuser@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    fill_in "Display name", with: "New User"

    click_on "Sign up"

    assert_text "Notes"
  end

  test "user signs in successfully" do
    visit sign_in_url

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"

    click_on "Sign in"

    assert_text "Notes"
  end

  test "user signs out successfully" do
    visit sign_in_url

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_on "Sign in"

    click_on "Sign out"

    assert_text "Sign in"
  end
end
