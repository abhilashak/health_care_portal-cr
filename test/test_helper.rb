ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Load custom test helpers
require_relative "support/healthcare_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Include custom test helper modules
    include HealthcareTestHelper

    # Healthcare application specific test helpers

    # Helper method to create valid timestamps for healthcare records
    def valid_healthcare_timestamp
      Time.current
    end

    # Helper method to generate test phone numbers
    def valid_phone_number
      "+1#{rand(1000000000..9999999999)}"
    end

    # Helper method to generate test email addresses
    def valid_email(prefix = "test")
      "#{prefix}#{rand(1000..9999)}@healthcareportal.test"
    end

    # Helper method to create valid date ranges for appointments
    def valid_appointment_date
      Date.current + rand(1..30).days
    end

    # Helper method to create valid time slots for appointments
    def valid_appointment_time
      base_time = Time.current.beginning_of_day + 9.hours # Start at 9 AM
      base_time + (rand(0..8) * 1.hour) # 9 AM to 5 PM
    end

    # Authentication helper (for when we add authentication)
    def sign_in_as(user)
      # This will be implemented when we add authentication
    end

    # Helper to assert healthcare data privacy compliance
    def assert_healthcare_data_privacy(response_body)
      # Ensure no sensitive data is exposed in responses
      assert_not_includes response_body.downcase, "ssn", "SSN found in response"
      assert_not_includes response_body.downcase, "social_security", "Social Security reference found in response"
      assert_not_includes response_body.downcase, "medical_record_number", "Medical record number found in response"
    end

    # Setup method for all tests
    def setup
      super
      # Basic test environment validation
      assert Rails.env.test?, "Tests should only run in test environment"
    end

    # Add more helper methods to be used by all tests here...
  end
end

# Integration test configuration
module ActionDispatch
  class IntegrationTest
    # Basic integration test setup for healthcare application
  end
end
