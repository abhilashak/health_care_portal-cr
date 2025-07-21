require "test_helper"

class ClinicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clean data for each test
    [ Appointment, Doctor, Patient, HealthcareFacility ].each(&:delete_all)

    # Create test clinics
    @clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Bay Area Family Clinic",
      address: "123 Family Health Street",
      phone: "+14155556789",
      email: "appointments@bayareafamily.com",
      registration_number: "CLI001",
      active: true,
      status: "active"
    )

    @urgent_care = HealthcareFacility.create!(
      type: "Clinic",
      name: "QuickCare Urgent Care",
      address: "456 Urgent Care Avenue",
      phone: "+14085554567",
      email: "info@quickcareurgent.com",
      registration_number: "CLI002",
      active: true,
      status: "active"
    )

    # Create test doctor associated with clinic
    @doctor = Doctor.create!(
      first_name: "Dr. Jennifer",
      last_name: "Brown",
      specialization: "Family Medicine",
      clinic: @clinic
    )

    # Create test patient
    @patient = Patient.create!(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@email.com",
      date_of_birth: 30.years.ago.to_date
    )
  end

  # INDEX action tests
  test "should get index" do
    get clinics_url
    assert_response :success
    assert_includes @response.body, @clinic.name
    assert_includes @response.body, @urgent_care.name
  end

  test "should get index as JSON" do
    get clinics_url, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 2, json_response.length
    assert_includes json_response.map { |c| c["name"] }, @clinic.name
  end

  test "should filter clinics by name" do
    get clinics_url, params: { search: "Family" }
    assert_response :success
    assert_includes @response.body, @clinic.name
    assert_not_includes @response.body, @urgent_care.name
  end

  test "should filter clinics by services" do
    get clinics_url, params: { service: "urgent care" }
    assert_response :success
  end

  test "should filter clinics that accept walk-ins" do
    get clinics_url, params: { walk_ins: true }
    assert_response :success
  end

  # SHOW action tests
  test "should show clinic" do
    get clinic_url(@clinic)
    assert_response :success
    assert_includes @response.body, @clinic.name
    assert_includes @response.body, @clinic.address
  end

  test "should show clinic as JSON" do
    get clinic_url(@clinic), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal @clinic.name, json_response["name"]
    assert_equal @clinic.email, json_response["email"]
  end

  test "should return 404 for non-existent clinic" do
    get clinic_url(id: 99999)
    assert_response :not_found
  end

  # NEW action tests
  test "should get new" do
    get new_clinic_url
    assert_response :success
    assert_includes @response.body, "New Clinic"
  end

  # CREATE action tests
  test "should create clinic" do
    assert_difference("HealthcareFacility.count") do
      post clinics_url, params: {
        clinic: {
          name: "New Family Clinic",
          address: "789 Health Street",
          phone: "+14155559999",
          email: "info@newfamily.com"
        }
      }
    end

    assert_redirected_to clinic_url(HealthcareFacility.last)
    assert_equal "Clinic was successfully created.", flash[:notice]
  end

  test "should create clinic as JSON" do
    assert_difference("HealthcareFacility.count") do
      post clinics_url, params: {
        clinic: {
          name: "API Family Clinic",
          address: "789 API Street",
          phone: "+14155559998",
          email: "api@family.com"
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(@response.body)
    assert_equal "API Family Clinic", json_response["name"]
  end

  test "should not create clinic with invalid data" do
    assert_no_difference("HealthcareFacility.count") do
      post clinics_url, params: {
        clinic: {
          name: "", # Invalid - blank name
          address: "789 Health Street",
          phone: "+14155559999",
          email: "invalid-email" # Invalid email format
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Name can't be blank"
  end

  test "should not create clinic with invalid data as JSON" do
    assert_no_difference("HealthcareFacility.count") do
      post clinics_url, params: {
        clinic: {
          name: "",
          address: "",
          phone: "",
          email: ""
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(@response.body)
    assert json_response["errors"].present?
  end

  # EDIT action tests
  test "should get edit" do
    get edit_clinic_url(@clinic)
    assert_response :success
    assert_includes @response.body, @clinic.name
  end

  # UPDATE action tests
  test "should update clinic" do
    patch clinic_url(@clinic), params: {
      clinic: {
        name: "Updated Clinic Name",
        address: @clinic.address,
        phone: @clinic.phone,
        email: @clinic.email
      }
    }

    assert_redirected_to clinic_url(@clinic)
    assert_equal "Clinic was successfully updated.", flash[:notice]
    @clinic.reload
    assert_equal "Updated Clinic Name", @clinic.name
  end

  test "should update clinic as JSON" do
    patch clinic_url(@clinic), params: {
      clinic: {
        name: "JSON Updated Clinic",
        address: @clinic.address,
        phone: @clinic.phone,
        email: @clinic.email
      }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(@response.body)
    assert_equal "JSON Updated Clinic", json_response["name"]
  end

  test "should not update clinic with invalid data" do
    patch clinic_url(@clinic), params: {
      clinic: {
        name: "", # Invalid
        email: "invalid-email"
      }
    }

    assert_response :unprocessable_entity
    @clinic.reload
    assert_not_equal "", @clinic.name # Should not have changed
  end

  # DESTROY action tests
  test "should destroy clinic" do
    # Create clinic without doctors to allow deletion
    empty_clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Empty Clinic",
      address: "999 Empty Street",
      phone: "+14155550000",
      email: "empty@clinic.com"
    )

    assert_difference("HealthcareFacility.count", -1) do
      delete clinic_url(empty_clinic)
    end

    assert_redirected_to clinics_url
    assert_equal "Clinic was successfully deleted.", flash[:notice]
  end

  test "should destroy clinic as JSON" do
    empty_clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Empty API Clinic",
      address: "999 API Street",
      phone: "+14155550001",
      email: "empty.api@clinic.com"
    )

    assert_difference("HealthcareFacility.count", -1) do
      delete clinic_url(empty_clinic), as: :json
    end

    assert_response :no_content
  end

  test "should not destroy clinic with associated doctors" do
    # Clinic has associated doctor, should not be deletable
    assert_no_difference("HealthcareFacility.count") do
      delete clinic_url(@clinic)
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Cannot delete clinic with associated doctors"
  end

  # Custom endpoints tests
  test "should get clinic doctors" do
    get clinic_doctors_url(@clinic)
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  test "should get clinic doctors as JSON" do
    get clinic_doctors_url(@clinic), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
    assert_equal @doctor.full_name, json_response.first["full_name"]
  end

  test "should get clinic appointments" do
    # Create appointment for testing
    appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    get clinic_appointments_url(@clinic)
    assert_response :success
    assert_includes @response.body, "Appointments"
  end

  test "should get clinic appointments as JSON" do
    appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    get clinic_appointments_url(@clinic), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
  end

  test "should get clinic statistics" do
    get clinic_statistics_url(@clinic)
    assert_response :success
    assert_includes @response.body, "Statistics"
  end

  test "should get clinic statistics as JSON" do
    get clinic_statistics_url(@clinic), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("doctor_count")
    assert json_response.key?("patient_count")
    assert json_response.key?("services_offered")
  end

  test "should search clinics by specialization" do
    get search_clinics_url, params: { specialization: "Family Medicine" }
    assert_response :success
    assert_includes @response.body, @clinic.name
  end

  test "should get available appointment slots" do
    get clinic_available_slots_url(@clinic), params: { date: 1.week.from_now.to_date }
    assert_response :success
  end

  test "should get available appointment slots as JSON" do
    get clinic_available_slots_url(@clinic), params: { date: 1.week.from_now.to_date }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("available_slots")
  end

  test "should get nearby clinics" do
    get nearby_clinics_url, params: { latitude: 37.7749, longitude: -122.4194, radius: 10 }
    assert_response :success
  end

  test "should get nearby clinics as JSON" do
    get nearby_clinics_url, params: { latitude: 37.7749, longitude: -122.4194, radius: 10 }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.is_a?(Array)
  end

  # Walk-in availability tests
  test "should check walk-in availability" do
    get clinic_walk_in_availability_url(@clinic)
    assert_response :success
  end

  test "should check walk-in availability as JSON" do
    get clinic_walk_in_availability_url(@clinic), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("accepts_walk_ins")
    assert json_response.key?("current_wait_time")
  end

  # Services tests
  test "should get clinic services" do
    get clinic_services_url(@clinic)
    assert_response :success
  end

  test "should get clinic services as JSON" do
    get clinic_services_url(@clinic), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("services")
  end

  # Error handling tests
  test "should handle invalid clinic ID gracefully" do
    get clinic_url(id: "invalid")
    assert_response :not_found
  end

  test "should handle server errors gracefully" do
    # Simulate server error by stubbing
    HealthcareFacility.stub :find, -> { raise StandardError.new("Test error") } do
      get clinic_url(@clinic)
      assert_response :internal_server_error
    end
  end

  # Pagination tests
  test "should paginate clinics list" do
    # Create more clinics to test pagination
    15.times do |i|
      HealthcareFacility.create!(
        type: "Clinic",
        name: "Clinic #{i}",
        address: "#{i} Medical Street",
        phone: "+1415555#{i.to_s.rjust(4, '0')}",
        email: "clinic#{i}@test.com"
      )
    end

    get clinics_url, params: { page: 2, per_page: 10 }
    assert_response :success
  end

  # Sorting tests
  test "should sort clinics by name" do
    get clinics_url, params: { sort: "name", direction: "asc" }
    assert_response :success
  end

  test "should sort clinics by creation date" do
    get clinics_url, params: { sort: "created_at", direction: "desc" }
    assert_response :success
  end

  # Filtering tests
  test "should filter clinics by operating hours" do
    get clinics_url, params: { open_now: true }
    assert_response :success
  end

  test "should filter clinics by insurance acceptance" do
    get clinics_url, params: { accepts_insurance: true }
    assert_response :success
  end
end
