require "test_helper"

class ConnectionsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
  end

  test "user can send, accept, and manage connection requests" do
    sign_in_as(@alice)

    # View connections page
    get connections_url
    assert_response :success

    # Send connection request to Bob
    assert_difference("Connection.count") do
      post connections_url, params: { email: @bob.email }
    end

    assert_redirected_to connections_url
    follow_redirect!

    connection = Connection.last

    # Sign out and sign in as Bob
    delete sign_out_url
    sign_in_as(@bob)

    # Bob accepts the connection
    patch accept_connection_url(connection)
    assert_redirected_to connections_url
    assert_equal "accepted", connection.reload.status

    # View connected users
    get connections_url
    assert_response :success
  end

  test "user can reject connection requests" do
    pending_connection = connections(:alice_charlie_pending)

    sign_in_as(@charlie)

    patch reject_connection_url(pending_connection)
    assert_redirected_to connections_url
    assert_equal "rejected", pending_connection.reload.status
  end

  test "user can remove connections" do
    connection = connections(:alice_bob)

    sign_in_as(@alice)

    assert_difference("Connection.count", -1) do
      delete connection_url(connection)
    end

    assert_redirected_to connections_url
  end

  test "user cannot connect with themselves" do
    sign_in_as(@alice)

    assert_no_difference("Connection.count") do
      post connections_url, params: { email: @alice.email }
    end

    assert_redirected_to connections_url
  end

  test "user cannot connect with non-existent user" do
    sign_in_as(@alice)

    assert_no_difference("Connection.count") do
      post connections_url, params: { email: "nonexistent@example.com" }
    end

    assert_redirected_to connections_url
  end
end
