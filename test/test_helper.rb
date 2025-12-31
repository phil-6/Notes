ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Disable parallel testing for now
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Helper method to sign in a user in integration tests
    def sign_in_as(user)
      post sign_in_url, params: { email: user.email, password: "password123" }
      assert_redirected_to root_url
      follow_redirect!
    end
  end
end
