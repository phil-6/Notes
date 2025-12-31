require "application_system_test_case"

class ConnectionsTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    sign_in(@alice)
  end

  test "user sends a connection request" do
    visit connections_url

    fill_in "Email", with: @bob.email
    click_on "Send Request"

    assert_text "Connection request sent"
  end

  test "user accepts a connection request" do
    connection = connections(:alice_charlie_pending)

    # Sign in as Charlie who received the request
    click_on "Sign out"
    sign_in(users(:charlie))

    visit connections_url

    within "#connection_#{connection.id}" do
      click_on "Accept"
    end

    assert_text "Connection accepted"
  end

  test "user views their connections" do
    visit connections_url

    # Alice is connected with Bob
    assert_text @bob.display_name
  end

  private
  def sign_in(user)
    visit sign_in_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Sign in"
  end
end
