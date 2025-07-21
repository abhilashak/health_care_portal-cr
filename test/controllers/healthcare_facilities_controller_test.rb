require "test_helper"

class HealthcareFacilitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get healthcare_facilities_dashboard_url
    assert_response :success
  end
end
