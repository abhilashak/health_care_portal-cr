require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clean data for each test
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

  test "should get index with search functionality" do
    get root_url
    assert_response :success
    assert_includes @response.body, @hospital.name
    assert_includes @response.body, @clinic.name
  end

  test "should search hospitals by name" do
    get root_url, params: { hospital_search: "General" }
    assert_response :success
    assert_includes @response.body, @hospital.name
    assert_not_includes @response.body, @clinic.name
  end

  test "should search hospitals by address" do
    get root_url, params: { hospital_search: "Medical Center" }
    assert_response :success
    assert_includes @response.body, @hospital.name
  end

  test "should search clinics by name" do
    get root_url, params: { clinic_search: "Family" }
    assert_response :success
    assert_includes @response.body, @clinic.name
    assert_not_includes @response.body, @hospital.name
  end

  test "should search clinics by address" do
    get root_url, params: { clinic_search: "Health Street" }
    assert_response :success
    assert_includes @response.body, @clinic.name
  end

  test "should handle empty search gracefully" do
    get root_url, params: { hospital_search: "", clinic_search: "" }
    assert_response :success
    assert_includes @response.body, @hospital.name
    assert_includes @response.body, @clinic.name
  end

  test "should handle non-matching search" do
    get root_url, params: { hospital_search: "NonExistentHospital" }
    assert_response :success
    assert_not_includes @response.body, @hospital.name
    assert_not_includes @response.body, @clinic.name
  end
end
