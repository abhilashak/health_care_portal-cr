require "test_helper"

class PatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clean data for each test
    [ Appointment, Doctor, Patient, HealthcareFacility ].each(&:delete_all)

    # Create test healthcare facilities
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

    @clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Bay Area Family Clinic",
      address: "456 Family Health Street",
      phone: "+14155556789",
      email: "appointments@bayareafamily.com",
      registration_number: "CLI001",
      active: true,
      status: "active",
      password: "password123"
    )

    # Create test doctors
    @doctor = Doctor.create!(
      first_name: "Dr. John",
      last_name: "Smith",
      specialization: "Cardiology",
      hospital: @hospital,
      email: "dr.john.smith@hospital.com",
      password: "password123"
    )

    @family_doctor = Doctor.create!(
      first_name: "Dr. Jennifer",
      last_name: "Brown",
      specialization: "Family Medicine",
      clinic: @clinic,
      email: "dr.jennifer.brown@clinic.com",
      password: "password123"
    )

    # Create test patients
    @patient = Patient.create!(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@email.com",
      date_of_birth: 30.years.ago.to_date,
      password: "password123"
    )

    @patient2 = Patient.create!(
      first_name: "Jane",
      last_name: "Smith",
      email: "jane.smith@email.com",
      date_of_birth: 25.years.ago.to_date,
      password: "password123"
    )
  end

  # Basic functionality tests
  test "should get index" do
    get patients_path
    assert_response :success
  end

  test "should get new" do
    get new_patient_path
    assert_response :success
  end

  test "should create patient" do
    assert_difference("Patient.count") do
      post patients_path, params: {
        patient: {
          first_name: "Test",
          last_name: "Patient",
          email: "test.patient@email.com",
          date_of_birth: 35.years.ago.to_date,
          password: "password123"
        }
      }
    end
    assert_redirected_to patient_path(Patient.last)
  end

  test "should show patient" do
    get patient_path(@patient)
    assert_response :success
  end

  test "should get edit" do
    get edit_patient_path(@patient)
    assert_response :success
  end

  test "should update patient" do
    patch patient_path(@patient), params: {
      patient: {
        first_name: "Updated"
      }
    }
    assert_redirected_to patient_path(@patient)
    @patient.reload
    assert_equal "Updated", @patient.first_name
  end

  test "should destroy patient" do
    assert_difference("Patient.count", -1) do
      delete patient_path(@patient)
    end
    assert_redirected_to patients_path
  end

  # JSON API tests
  test "should get index as JSON" do
    get patients_path, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length
  end

  test "should show patient as JSON" do
    get patient_path(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @patient.id, json_response["id"]
  end

  test "should create patient as JSON" do
    assert_difference("Patient.count") do
      post patients_path, params: {
        patient: {
          first_name: "Test",
          last_name: "Patient",
          email: "test.patient@email.com",
          date_of_birth: 35.years.ago.to_date,
          password: "password123"
        }
      }, as: :json
    end
    assert_response :success
  end

  test "should update patient as JSON" do
    patch patient_path(@patient), params: {
      patient: {
        first_name: "Updated"
      }
    }, as: :json
    assert_response :success
    @patient.reload
    assert_equal "Updated", @patient.first_name
  end

  test "should destroy patient as JSON" do
    assert_difference("Patient.count", -1) do
      delete patient_path(@patient), as: :json
    end
    assert_response :success
  end
end
