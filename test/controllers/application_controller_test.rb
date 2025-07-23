require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clean data for each test in the correct order to avoid constraint violations
    [ Appointment, Doctor, Patient, HealthcareFacility ].each(&:delete_all)

    # Create test hospitals
    @hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "General Hospital",
      address: "123 Medical Center Drive",
      phone: "+14155551234",
      email: "info@generalhospital.com",
      registration_number: "HOS001",
      active: true,
      status: "active",
      password: "password123"
    )

    # Create test clinics
    @clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Family Health Clinic",
      address: "456 Health Street",
      phone: "+14155555678",
      email: "info@familyhealth.com",
      registration_number: "CLI001",
      active: true,
      status: "active",
      password: "password123"
    )
  end

  test "should get index" do
    get root_path
    assert_response :success
    assert_includes response.body, "Healthcare Portal"
  end

  test "should display hospitals and clinics" do
    get root_path
    assert_response :success
    assert_includes response.body, "General Hospital"
    assert_includes response.body, "Family Health Clinic"
  end

  test "should show correct counts" do
    get root_path
    assert_response :success
    assert_includes response.body, "Total Hospitals"
    assert_includes response.body, "Total Clinics"
  end

  test "should handle empty search gracefully" do
    get root_path, params: { hospital_search: "", clinic_search: "" }
    assert_response :success
    assert_includes response.body, "Healthcare Portal"
  end

  test "should handle non-matching search" do
    get root_path, params: { hospital_search: "NonExistentHospital" }
    assert_response :success
    assert_includes response.body, "No hospitals found"
  end
end
