require "test_helper"

class SharedNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
    @alice_note = notes(:alice_note_one)
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

    assert_difference("SharedWith.count") do
      post note_shared_notes_url(@alice_note), params: { user_id: @bob.id, can_edit: true }
    end

    assert_redirected_to edit_note_url(@alice_note)
  end

  test "should not share note with non-connected user" do
    sign_in_as(@bob)
    bob_note = notes(:bob_note)

    assert_no_difference("SharedWith.count") do
      post note_shared_notes_url(bob_note), params: { user_id: @charlie.id }
    end

    assert_redirected_to edit_note_url(bob_note)
  end

  test "should unshare note" do
    sign_in_as(@alice)
    shared_with = shared_withs(:alice_shares_with_bob_can_edit)

    assert_difference("SharedWith.count", -1) do
      delete note_shared_note_url(@alice_note, shared_with)
    end

    assert_redirected_to edit_note_url(@alice_note)
  end

  test "should not unshare note if not owner" do
    sign_in_as(@bob)
    shared_with = shared_withs(:alice_shares_with_bob_can_edit)

    assert_no_difference("SharedWith.count") do
      delete note_shared_note_url(@alice_note, shared_with)
    end

    assert_redirected_to root_url
  end

  test "should only access own notes when sharing" do
    sign_in_as(@bob)
    bob_note = notes(:bob_note)

    assert_raises(ActiveRecord::RecordNotFound) do
      post note_shared_notes_url(@alice_note), params: { user_id: @charlie.id }
    end
  end
end
