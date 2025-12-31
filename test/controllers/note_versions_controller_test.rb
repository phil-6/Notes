require "test_helper"

class NoteVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @alice_note = notes(:alice_note_one)

    # Create a version for testing
    @alice_note.version_user = @alice
    @alice_note.update(title: "Updated Title")
    @version = @alice_note.versions.last
  end

  test "should require authentication" do
    get note_versions_url(@alice_note)
    assert_redirected_to sign_in_url
  end

  test "should get index when authenticated" do
    sign_in_as(@alice)
    get note_versions_url(@alice_note)
    assert_response :success
  end

  test "should show version" do
    sign_in_as(@alice)
    get note_version_url(@alice_note, @version)
    assert_response :success
  end

  test "should restore version" do
    sign_in_as(@alice)
    original_title = @version.title

    post restore_note_version_url(@alice_note, @version)

    assert_redirected_to note_versions_url(@alice_note)
    assert_equal original_title, @alice_note.reload.title
  end

  test "should only access own notes versions" do
    # Create a note for Charlie that Bob can't access
    charlie = users(:charlie)
    charlie_note = charlie.notes.create!(title: "Charlie's Note", color: "blue")
    charlie_note.version_user = charlie
    charlie_note.update(title: "Updated")

    sign_in_as(@bob)

    # Should get 404 when trying to access versions of note Bob doesn't own
    get note_versions_url(charlie_note)
    assert_response :not_found
  end

  test "should create version when restoring" do
    sign_in_as(@alice)
    initial_count = @alice_note.versions.count

    post restore_note_version_url(@alice_note, @version)

    assert_equal initial_count + 1, @alice_note.versions.count
  end
end
