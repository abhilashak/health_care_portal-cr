require "test_helper"

class DoctorsControllerTest < ActionDispatch::IntegrationTest
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

    @clinic_doctor = Doctor.create!(
      first_name: "Dr. Jennifer",
      last_name: "Brown",
      specialization: "Family Medicine",
      clinic: @clinic,
      email: "dr.jennifer.brown@clinic.com",
      password: "password123"
    )
  end

  # Basic functionality tests
  test "should get index" do
    get doctors_path
    assert_response :success
  end

  test "should get new" do
    get new_doctor_path
    assert_response :success
  end

  test "should create doctor" do
    assert_difference("Doctor.count") do
      post doctors_path, params: {
        doctor: {
          first_name: "Dr. Test",
          last_name: "Doctor",
          specialization: "Internal Medicine",
          hospital_id: @hospital.id,
          email: "dr.test@hospital.com",
          password: "password123"
        }
      }
    end
    assert_redirected_to doctor_path(Doctor.last)
  end

  test "should show doctor" do
    get doctor_path(@doctor)
    assert_response :success
  end

  test "should get edit" do
    get edit_doctor_path(@doctor)
    assert_response :success
  end

  test "should update doctor" do
    patch doctor_path(@doctor), params: {
      doctor: {
        specialization: "Neurology"
      }
    }
    assert_redirected_to doctor_path(@doctor)
    @doctor.reload
    assert_equal "Neurology", @doctor.specialization
  end

  test "should destroy doctor" do
    assert_difference("Doctor.count", -1) do
      delete doctor_path(@doctor)
    end
    assert_redirected_to doctors_path
  end

  # JSON API tests
  test "should get index as JSON" do
    get doctors_path, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length
  end

  test "should show doctor as JSON" do
    get doctor_path(@doctor), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @doctor.id, json_response["id"]
  end

  test "should create doctor as JSON" do
    assert_difference("Doctor.count") do
      post doctors_path, params: {
        doctor: {
          first_name: "Dr. Test",
          last_name: "Doctor",
          specialization: "Internal Medicine",
          hospital_id: @hospital.id,
          email: "dr.test@hospital.com",
          password: "password123"
        }
      }, as: :json
    end
    assert_response :success
  end

  test "should update doctor as JSON" do
    patch doctor_path(@doctor), params: {
      doctor: {
        specialization: "Neurology"
      }
    }, as: :json
    assert_response :success
    @doctor.reload
    assert_equal "Neurology", @doctor.specialization
  end

  test "should destroy doctor as JSON" do
    assert_difference("Doctor.count", -1) do
      delete doctor_path(@doctor), as: :json
    end
    assert_response :success
  end
end
