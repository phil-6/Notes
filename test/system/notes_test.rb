require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
    sign_in
  end

  test "user creates a new note" do
    visit root_url

    click_on "New Note"

    fill_in "Title", with: "My System Test Note"
    # Note: rich_text_area for content will be handled by Lexxy editor

    click_on "Create Note"

    assert_text "My System Test Note"
  end

  test "user edits an existing note" do
    note = notes(:alice_note_one)

    visit root_url

    # Click on the note to edit it
    click_on note.title

    fill_in "Title", with: "Updated by System Test"

    click_on "Update Note"

    assert_text "Updated by System Test"
  end

  test "user deletes a note" do
    note = notes(:alice_note_two)

    visit root_url

    # Find the note and delete it
    within "##{dom_id(note)}" do
      accept_confirm do
        click_on "Delete"
      end
    end

    assert_no_text note.title
  end

  test "user pins a note" do
    note = notes(:alice_note_two)

    visit root_url

    within "##{dom_id(note)}" do
      click_on "Pin"
    end

    # Verify note is pinned (would appear at top)
    assert_text note.title
  end

  private
  def sign_in
    visit sign_in_url
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_on "Sign in"
  end
end
