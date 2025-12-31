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

    # Create a new unpinned note
    new_note = @user.notes.create!(title: "Unpinned Note", color: "blue", pinned: false)

    # Pin note
    assert_not new_note.pinned?
    patch pin_note_url(new_note)
    assert new_note.reload.pinned?

    # Unpin note
    patch unpin_note_url(new_note)
    assert_not new_note.reload.pinned?
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
    @note.update(title: "First Update")
    first_update_version = @note.versions.last
    @note.update(title: "Second Update")

    # View versions
    get note_versions_url(@note)
    assert_response :success

    # Restore to "First Update" version
    post restore_note_version_url(@note, first_update_version)

    assert_redirected_to note_versions_url(@note)
    assert_equal "First Update", @note.reload.title
  end

  test "user cannot access another user's notes" do
    # Create Charlie note (not shared with Alice)
    charlie = users(:charlie)
    charlie_note = charlie.notes.create!(title: "Charlie's Private Note", color: "red")

    sign_in_as(@user)

    # Should get redirected with alert when trying to access notes that don't belong to user
    get edit_note_url(charlie_note)
    assert_redirected_to notes_url
    follow_redirect!
    assert_match /not found/i, flash[:alert]

    patch note_url(charlie_note), params: { note: { title: "Hacked" } }
    assert_redirected_to notes_url

    delete note_url(charlie_note)
    assert_redirected_to notes_url
  end
end
