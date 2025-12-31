require "test_helper"

class SharingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
    @alice_note = notes(:alice_note_one)
  end

  test "user can share note with connected user" do
    sign_in_as(@alice)

    # Create a new note that isn't shared yet
    new_note = @alice.notes.create!(title: "New Note for Sharing", color: "blue")

    get edit_note_url(new_note)
    assert_response :success

    # Share with Bob (connected)
    assert_difference("SharedWith.count") do
      post note_shared_notes_url(new_note), params: {
        user_id: @bob.id,
        can_edit: true
      }
    end

    assert_redirected_to edit_note_url(new_note)
    follow_redirect!

    shared_with = SharedWith.last
    assert_equal new_note, shared_with.note
    assert_equal @bob, shared_with.user
    assert shared_with.can_edit
  end

  test "user can share note with read-only permission" do
    sign_in_as(@alice)

    # Create a new note for this test
    new_note = @alice.notes.create!(title: "Another Note for Sharing", color: "green")

    assert_difference("SharedWith.count") do
      post note_shared_notes_url(new_note), params: {
        user_id: @bob.id,
        can_edit: false
      }
    end

    shared_with = SharedWith.last
    assert_not shared_with.can_edit
  end

  test "user can unshare note" do
    sign_in_as(@alice)
    shared_with = shared_withs(:alice_shares_with_bob_can_edit)

    assert_difference("SharedWith.count", -1) do
      delete note_shared_note_url(@alice_note, shared_with)
    end

    assert_redirected_to edit_note_url(@alice_note)
  end

  test "user can view shared notes" do
    sign_in_as(@bob)

    get shared_with_me_url
    assert_response :success
  end

  test "shared user with edit permission can edit note" do
    sign_in_as(@bob)

    # Bob can edit alice_note_one because he has edit permission
    get edit_note_url(@alice_note)
    assert_response :success

    patch note_url(@alice_note), params: {
      note: { title: "Bob's Edit" }
    }

    # Should succeed since Bob has edit permission
    assert_equal "Bob's Edit", @alice_note.reload.title
  end

  test "shared user without edit permission cannot edit note" do
    alice_note_two = notes(:alice_note_two)

    sign_in_as(@charlie)

    # Charlie has read-only access to alice_note_two
    assert_not alice_note_two.can_be_edited_by?(@charlie)
  end

  test "user cannot share note with non-connected user" do
    sign_in_as(@alice)

    # Create a new user who isn't connected to Alice
    non_connected_user = User.create!(
      email: "nonconnected@example.com",
      password: "password123",
      password_confirmation: "password123",
      display_name: "Not Connected"
    )

    new_note = @alice.notes.create!(title: "Private Note", color: "red")

    # Should not be able to share with non-connected user
    assert_no_difference("SharedWith.count") do
      post note_shared_notes_url(new_note), params: {
        user_id: non_connected_user.id
      }
    end

    assert_redirected_to edit_note_url(new_note)
  end
end
