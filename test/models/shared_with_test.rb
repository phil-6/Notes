require "test_helper"

class SharedWithTest < ActiveSupport::TestCase
  def setup
    @alice = users(:alice)
    @bob = users(:bob)
    @note = notes(:alice_note_one)
    @shared_with = shared_withs(:alice_shares_with_bob_can_edit)
  end

  # Validations
  test "should validate uniqueness of user_id scoped to note_id" do
    duplicate = SharedWith.new(note: @note, user: @bob, can_edit: false)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "should allow same user for different notes" do
    other_note = notes(:alice_note_two)
    shared = SharedWith.new(note: other_note, user: @bob, can_edit: true)
    assert shared.valid?
  end

  # Associations
  test "should belong to note" do
    assert_equal @note, @shared_with.note
  end

  test "should belong to user" do
    assert_equal @bob, @shared_with.user
  end

  # Scopes
  test "can_edit scope should return only editable shares" do
    editable = SharedWith.can_edit
    assert_includes editable, shared_withs(:alice_shares_with_bob_can_edit)
    assert_not_includes editable, shared_withs(:alice_shares_with_charlie_read_only)
  end

  test "read_only scope should return only read-only shares" do
    read_only = SharedWith.read_only
    assert_includes read_only, shared_withs(:alice_shares_with_charlie_read_only)
    assert_not_includes read_only, shared_withs(:alice_shares_with_bob_can_edit)
  end

  # Default values
  test "should default can_edit to false" do
    shared = SharedWith.create!(note: notes(:charlie_note), user: @bob)
    assert_equal false, shared.can_edit
  end

  test "should allow setting can_edit to true" do
    shared = SharedWith.create!(note: notes(:charlie_note), user: @bob, can_edit: true)
    assert_equal true, shared.can_edit
  end
end
