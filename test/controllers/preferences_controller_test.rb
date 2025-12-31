require "test_helper"

class PreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
  end

  test "should require authentication" do
    patch preferences_url, params: { user: { dark_mode: true } }
    assert_redirected_to sign_in_url
  end

  test "should update dark mode preference" do
    sign_in_as(@alice)

    patch preferences_url, params: { user: { dark_mode: true } }

    assert @alice.reload.dark_mode
  end

  test "should toggle dark mode off" do
    sign_in_as(@alice)
    @alice.update(dark_mode: true)

    patch preferences_url, params: { user: { dark_mode: false } }

    assert_not @alice.reload.dark_mode
  end
end
