require "test_helper"

class SharedNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
    @alice_note_one = notes(:alice_note_one)
    @alice_note_two = notes(:alice_note_two)
  end

  test "should require authentication" do
    get shared_with_me_url
    assert_redirected_to sign_in_url
  end

  test "should get index when authenticated" do
    sign_in_as(@alice)
    get shared_with_me_url
    assert_response :success
  end

  test "should share note with connected user" do
    sign_in_as(@alice)

    # Use alice_note_two which isn't shared with Bob yet
    assert_difference("SharedWith.count") do
      post note_shared_notes_url(@alice_note_two), params: { user_id: @bob.id, can_edit: true }
    end

    assert_redirected_to edit_note_url(@alice_note_two)
  end

  test "should not share note with non-connected user" do
    sign_in_as(@alice)

    # Create a new user who isn't connected to Alice
    non_connected_user = User.create!(
      email: "notconnected@example.com",
      password: "password123",
      password_confirmation: "password123",
      display_name: "Not Connected"
    )

    assert_no_difference("SharedWith.count") do
      post note_shared_notes_url(@alice_note_two), params: { user_id: non_connected_user.id }
    end

    assert_redirected_to edit_note_url(@alice_note_two)
  end

  test "should unshare note" do
    sign_in_as(@alice)
    shared_with = shared_withs(:alice_shares_with_bob_can_edit)

    assert_difference("SharedWith.count", -1) do
      delete note_shared_note_url(@alice_note_one, shared_with)
    end

    assert_redirected_to edit_note_url(@alice_note_one)
  end

  test "should not unshare note if not owner" do
    sign_in_as(@bob)
    shared_with = shared_withs(:alice_shares_with_bob_can_edit)

    # Bob tries to unshare Alice's note - gets 404 since set_note only finds owned notes
    delete note_shared_note_url(@alice_note_one, shared_with)
    assert_response :not_found
  end

  test "should only access own notes when sharing" do
    sign_in_as(@bob)

    # Bob tries to share Alice's note - should get 404
    post note_shared_notes_url(@alice_note_one), params: { user_id: @charlie.id }
    assert_response :not_found
  end
end
