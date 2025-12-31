require "test_helper"

class NoteTest < ActiveSupport::TestCase
  def setup
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
    @alice_note = notes(:alice_note_one)
    @shared_note = notes(:alice_note_two)
    @locked_note = notes(:locked_note)
  end

  # Validations
  test "should validate color inclusion" do
    note = Note.new(user: @alice, title: "Test", color: "invalid_color")
    assert_not note.valid?
    assert_includes note.errors[:color], "is not included in the list"
  end

  test "should set default color on create" do
    note = Note.create!(user: @alice, title: "Test Note")
    assert_equal "default", note.color
  end

  # Locking methods
  test "lock! should set locked_by and locked_at" do
    note = notes(:alice_note_one)
    note.lock!(@bob)

    assert_equal @bob.id, note.locked_by_id
    assert_not_nil note.locked_at
    assert note.locked_at > 1.minute.ago
  end

  test "unlock! should clear locked_by and locked_at" do
    @locked_note.unlock!

    assert_nil @locked_note.locked_by_id
    assert_nil @locked_note.locked_at
  end

  test "locked? should return true when locked within timeout" do
    note = notes(:alice_note_one)
    note.lock!(@bob)

    assert note.locked?
  end

  test "locked? should return false when lock expired" do
    note = notes(:alice_note_one)
    note.update(locked_by: @bob, locked_at: 10.minutes.ago)

    assert_not note.locked?
  end

  test "locked? should return false when not locked" do
    note = notes(:alice_note_one)
    assert_not note.locked?
  end

  test "locked_by? should return true when locked by specific user" do
    @locked_note.lock!(@bob)
    assert @locked_note.locked_by?(@bob)
    assert_not @locked_note.locked_by?(@alice)
  end

  # Permission methods
  test "can_be_edited_by? should allow owner to edit" do
    assert @alice_note.can_be_edited_by?(@alice)
  end

  test "can_be_edited_by? should allow collaborator with edit permission" do
    # Bob has edit permission on alice_note_one
    assert @alice_note.can_be_edited_by?(@bob)
  end

  test "can_be_edited_by? should deny collaborator without edit permission" do
    # Charlie has read-only on alice_note_two
    assert_not @shared_note.can_be_edited_by?(@charlie)
  end

  test "can_be_edited_by? should deny non-collaborator" do
    assert_not @alice_note.can_be_edited_by?(@charlie)
  end

  test "editable_by? should allow owner even when locked by others" do
    @alice_note.lock!(@bob)
    assert @alice_note.editable_by?(@alice)
  end

  test "editable_by? should deny when locked by another user" do
    @alice_note.lock!(@alice)
    assert_not @alice_note.editable_by?(@bob)
  end

  test "editable_by? should allow when locked by same user" do
    @alice_note.lock!(@bob)
    assert @alice_note.editable_by?(@bob)
  end

  # Associations
  test "should belong to user" do
    assert_equal @alice, @alice_note.user
  end

  test "should have shared_withs" do
    assert_includes @alice_note.shared_with_users, @bob
  end

  test "should have optional locked_by user" do
    @locked_note.lock!(@bob)
    assert_equal @bob, @locked_note.locked_by
  end

  # Scopes
  test "pinned scope should return only pinned notes" do
    pinned = Note.pinned
    assert_includes pinned, @alice_note
    assert_not_includes pinned, notes(:alice_note_two)
  end

  test "unpinned scope should return only unpinned notes" do
    unpinned = Note.unpinned
    assert_includes unpinned, notes(:alice_note_two)
    assert_not_includes unpinned, @alice_note
  end

  # Versioning (existing functionality)
  test "should create initial version on create" do
    note = Note.create!(user: @alice, title: "New Note", color: "blue")
    assert_equal 1, note.versions.count
    assert_equal "created", note.versions.first.change_type
  end

  test "should create version on update" do
    initial_count = @alice_note.versions.count
    @alice_note.update(title: "Updated Title")
    assert_equal initial_count + 1, @alice_note.versions.count
  end

  test "should track version user" do
    @alice_note.version_user = @bob
    @alice_note.update(title: "Updated by Bob")
    assert_equal @bob, @alice_note.versions.last.created_by
  end
end
