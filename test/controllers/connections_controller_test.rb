require "test_helper"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
  end

  test "should require authentication" do
    get connections_url
    assert_redirected_to sign_in_url
  end

  test "should get index when authenticated" do
    sign_in_as(@alice)
    get connections_url
    assert_response :success
  end

  test "should create connection request" do
    sign_in_as(@bob)

    assert_difference("Connection.count") do
      post connections_url, params: { email: @alice.email }
    end

    assert_redirected_to connections_url
  end

  test "should not create connection to non-existent user" do
    sign_in_as(@alice)

    assert_no_difference("Connection.count") do
      post connections_url, params: { email: "nonexistent@example.com" }
    end

    assert_redirected_to connections_url
  end

  test "should not create connection to self" do
    sign_in_as(@alice)

    assert_no_difference("Connection.count") do
      post connections_url, params: { email: @alice.email }
    end

    assert_redirected_to connections_url
  end

  test "should not create duplicate connection" do
    sign_in_as(@alice)

    assert_no_difference("Connection.count") do
      post connections_url, params: { email: @bob.email }
    end

    assert_redirected_to connections_url
  end

  test "should accept connection" do
    sign_in_as(@charlie)
    connection = connections(:alice_charlie_pending)

    patch accept_connection_url(connection)

    assert_redirected_to connections_url
    assert_equal "accepted", connection.reload.status
  end

  test "should reject connection" do
    sign_in_as(@charlie)
    connection = connections(:alice_charlie_pending)

    patch reject_connection_url(connection)

    assert_redirected_to connections_url
    assert_equal "rejected", connection.reload.status
  end

  test "should destroy connection" do
    sign_in_as(@alice)
    connection = connections(:alice_bob)

    assert_difference("Connection.count", -1) do
      delete connection_url(connection)
    end

    assert_redirected_to connections_url
  end

  test "should not allow unauthorized connection access" do
    sign_in_as(@charlie)
    connection = connections(:alice_bob)

    patch accept_connection_url(connection)
    assert_redirected_to connections_url
  end
end
