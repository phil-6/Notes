require "application_system_test_case"

class SharingTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @note = notes(:alice_note_one)
    sign_in(@alice)
  end

  test "user shares a note with a connection" do
    visit edit_note_url(@note)

    # Share with Bob
    within ".share-section" do
      select @bob.display_name, from: "Share with"
      check "Can edit" if has_field?("Can edit")
      click_on "Share"
    end

    assert_text "Note shared"
  end

  test "user views shared notes" do
    # Sign out and sign in as Bob
    click_on "Sign out"
    sign_in(@bob)

    visit shared_with_me_url

    # Bob should see notes shared with him
    assert_text "Shared Notes"
  end

  test "user unshares a note" do
    shared_with = shared_withs(:alice_shares_with_bob_can_edit)

    visit edit_note_url(@note)

    within "#shared_with_#{shared_with.id}" do
      accept_confirm do
        click_on "Remove"
      end
    end

    assert_text "Unshared"
  end

  private
  def sign_in(user)
    visit sign_in_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Sign in"
  end
end
