require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_path
    assert_response :success
  end

  test "should get create" do
    # Create a test user first
    user = HealthcareFacility.create!(
      type: "Hospital",
      name: "Test Hospital",
      address: "123 Test St",
      phone: "+14155551234",
      email: "test@hospital.com",
      registration_number: "TEST001",
      active: true,
      status: "active",
      password: "password123"
    )

    post login_path, params: { user_type: "facility", email: user.email, password: "password123" }
    assert_response :redirect
  end

  test "should get destroy" do
    delete logout_path
    assert_response :redirect
  end
end
