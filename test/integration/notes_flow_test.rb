require "test_helper"

class NotesFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @note = notes(:alice_note_one)
  end

  test "user can create, edit, and delete a note" do
    sign_in_as(@user)

    # Create note
    get new_note_url
    assert_response :success

    assert_difference("Note.count") do
      post notes_url, params: {
        note: {
          title: "My New Note",
          color: "blue"
        }
      }
    end

    assert_redirected_to notes_url
    follow_redirect!
    assert_response :success

    new_note = Note.last

    # Edit note
    get edit_note_url(new_note)
    assert_response :success

    patch note_url(new_note), params: {
      note: {
        title: "Updated Title",
        color: "green"
      }
    }

    assert_redirected_to notes_url
    assert_equal "Updated Title", new_note.reload.title
    assert_equal "green", new_note.color

    # Delete note
    assert_difference("Note.count", -1) do
      delete note_url(new_note)
    end

    assert_redirected_to notes_url
  end

  test "user can pin and unpin notes" do
    sign_in_as(@user)

    # Pin note
    assert_not @note.pinned?
    patch pin_note_url(@note)
    assert @note.reload.pinned?

    # Unpin note
    patch unpin_note_url(@note)
    assert_not @note.reload.pinned?
  end

  test "user can lock and unlock notes" do
    sign_in_as(@user)

    # Lock note
    assert_not @note.locked?
    post lock_note_url(@note)
    assert @note.reload.locked?

    # Unlock note
    delete unlock_note_url(@note)
    assert_not @note.reload.locked?
  end

  test "user can view version history and restore versions" do
    sign_in_as(@user)

    # Update note to create versions
    @note.version_user = @user
    original_title = @note.title
    @note.update(title: "First Update")
    @note.update(title: "Second Update")

    # View versions
    get note_versions_url(@note)
    assert_response :success

    # Restore first version
    first_version = @note.versions.first
    post restore_note_version_url(@note, first_version)

    assert_redirected_to note_versions_url(@note)
    assert_equal original_title, @note.reload.title
  end

  test "user cannot access another user's notes" do
    sign_in_as(@user)
    bob_note = notes(:bob_note)

    assert_raises(ActiveRecord::RecordNotFound) do
      get edit_note_url(bob_note)
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      patch note_url(bob_note), params: { note: { title: "Hacked" } }
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      delete note_url(bob_note)
    end
  end
end
