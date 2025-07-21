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
      status: "active"
    )

    @clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Bay Area Family Clinic",
      address: "456 Family Health Street",
      phone: "+14155556789",
      email: "appointments@bayareafamily.com",
      registration_number: "CLI001",
      active: true,
      status: "active"
    )

    # Create test doctors
    @doctor = Doctor.create!(
      first_name: "Dr. John",
      last_name: "Smith",
      specialization: "Cardiology",
      hospital: @hospital
    )

    @clinic_doctor = Doctor.create!(
      first_name: "Dr. Jennifer",
      last_name: "Brown",
      specialization: "Family Medicine",
      clinic: @clinic
    )

    # Create another clinic for the independent doctor
    @private_clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Private Dermatology Clinic",
      address: "789 Private Practice Lane",
      phone: "+14155559999",
      email: "info@privatedermatology.com",
      registration_number: "CLI002",
      active: true,
      status: "active"
    )

    @independent_doctor = Doctor.create!(
      first_name: "Dr. James",
      last_name: "Anderson",
      specialization: "Dermatology",
      clinic: @private_clinic
    )

    # Create test patients
    @patient = Patient.create!(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@email.com",
      date_of_birth: 30.years.ago.to_date
    )

    @patient2 = Patient.create!(
      first_name: "Jane",
      last_name: "Smith",
      email: "jane.smith@email.com",
      date_of_birth: 25.years.ago.to_date
    )
  end

  # INDEX action tests
  test "should get index" do
    get doctors_url
    assert_response :success
    assert_includes @response.body, @doctor.full_name
    assert_includes @response.body, @clinic_doctor.full_name
    assert_includes @response.body, @independent_doctor.full_name
  end

  test "should get index as JSON" do
    get doctors_url, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 3, json_response.length
    assert_includes json_response.map { |d| d["full_name"] }, @doctor.full_name
  end

  test "should filter doctors by specialization" do
    get doctors_url, params: { specialization: "Cardiology" }
    assert_response :success
    assert_includes @response.body, @doctor.full_name
    assert_not_includes @response.body, @clinic_doctor.full_name
  end

  test "should filter doctors by hospital" do
    get doctors_url, params: { hospital_id: @hospital.id }
    assert_response :success
    assert_includes @response.body, @doctor.full_name
    assert_not_includes @response.body, @clinic_doctor.full_name
  end

  test "should filter doctors by clinic" do
    get doctors_url, params: { clinic_id: @clinic.id }
    assert_response :success
    assert_includes @response.body, @clinic_doctor.full_name
    assert_not_includes @response.body, @doctor.full_name
  end

  test "should search doctors by name" do
    get doctors_url, params: { search: "Smith" }
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  # SHOW action tests
  test "should show doctor" do
    get doctor_url(@doctor)
    assert_response :success
    assert_includes @response.body, @doctor.full_name
    assert_includes @response.body, @doctor.specialization
  end

  test "should show doctor as JSON" do
    get doctor_url(@doctor), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal @doctor.full_name, json_response["full_name"]
    assert_equal @doctor.specialization, json_response["specialization"]
  end

  test "should show doctor with hospital association" do
    get doctor_url(@doctor)
    assert_response :success
    assert_includes @response.body, @hospital.name
  end

  test "should show doctor with clinic association" do
    get doctor_url(@clinic_doctor)
    assert_response :success
    assert_includes @response.body, @clinic.name
  end

  test "should return 404 for non-existent doctor" do
    get doctor_url(id: 99999)
    assert_response :not_found
  end

  # NEW action tests
  test "should get new" do
    get new_doctor_url
    assert_response :success
    assert_includes @response.body, "New Doctor"
  end

  test "should get new with hospital preselected" do
    get new_doctor_url, params: { hospital_id: @hospital.id }
    assert_response :success
    assert_includes @response.body, @hospital.name
  end

  test "should get new with clinic preselected" do
    get new_doctor_url, params: { clinic_id: @clinic.id }
    assert_response :success
    assert_includes @response.body, @clinic.name
  end

  # CREATE action tests
  test "should create doctor" do
    assert_difference("Doctor.count") do
      post doctors_url, params: {
        doctor: {
          first_name: "Dr. Michael",
          last_name: "Johnson",
          email: "dr.johnson@hospital.com",
          specialization: "Emergency Medicine",
          hospital_id: @hospital.id
        }
      }
    end

    assert_redirected_to doctor_url(Doctor.last)
    assert_equal "Doctor was successfully created.", flash[:notice]
  end

  test "should create doctor as JSON" do
    assert_difference("Doctor.count") do
      post doctors_url, params: {
        doctor: {
          first_name: "Dr. API",
          last_name: "Doctor",
          email: "api.doctor@hospital.com",
          specialization: "Internal Medicine",
          clinic_id: @clinic.id
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(@response.body)
    assert_equal "Dr. API Doctor", json_response["full_name"]
  end

  test "should create independent doctor" do
    assert_difference("Doctor.count") do
      post doctors_url, params: {
        doctor: {
          first_name: "Dr. Independent",
          last_name: "Practitioner",
          email: "independent@private.com",
          specialization: "Psychiatry"
        }
      }
    end

    assert_redirected_to doctor_url(Doctor.last)
    created_doctor = Doctor.last
    assert_nil created_doctor.hospital_id
    assert_nil created_doctor.clinic_id
  end

  test "should not create doctor with invalid data" do
    assert_no_difference("Doctor.count") do
      post doctors_url, params: {
        doctor: {
          first_name: "", # Invalid - blank name
          last_name: "Test",
          email: "invalid-email", # Invalid email format
          specialization: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "First name can't be blank"
  end

  test "should not create doctor with duplicate email" do
    assert_no_difference("Doctor.count") do
      post doctors_url, params: {
        doctor: {
          first_name: "Dr. Duplicate",
          last_name: "Email",
          email: @doctor.email, # Duplicate email
          specialization: "Surgery"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Email has already been taken"
  end

  # EDIT action tests
  test "should get edit" do
    get edit_doctor_url(@doctor)
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  # UPDATE action tests
  test "should update doctor" do
    patch doctor_url(@doctor), params: {
      doctor: {
        first_name: "Dr. Updated",
        last_name: @doctor.last_name,
        email: @doctor.email,
        specialization: @doctor.specialization
      }
    }

    assert_redirected_to doctor_url(@doctor)
    assert_equal "Doctor was successfully updated.", flash[:notice]
    @doctor.reload
    assert_equal "Dr. Updated", @doctor.first_name
  end

  test "should update doctor as JSON" do
    patch doctor_url(@doctor), params: {
      doctor: {
        first_name: "Dr. JSON Updated",
        specialization: "Updated Cardiology"
      }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(@response.body)
    assert_equal "Dr. JSON Updated", json_response["first_name"]
  end

  test "should update doctor hospital association" do
    patch doctor_url(@independent_doctor), params: {
      doctor: {
        hospital_id: @hospital.id
      }
    }

    assert_redirected_to doctor_url(@independent_doctor)
    @independent_doctor.reload
    assert_equal @hospital.id, @independent_doctor.hospital_id
  end

  test "should not update doctor with invalid data" do
    patch doctor_url(@doctor), params: {
      doctor: {
        email: "invalid-email-format"
      }
    }

    assert_response :unprocessable_entity
    @doctor.reload
    assert_not_equal "invalid-email-format", @doctor.email
  end

  # DESTROY action tests
  test "should destroy doctor without appointments" do
    assert_difference("Doctor.count", -1) do
      delete doctor_url(@independent_doctor)
    end

    assert_redirected_to doctors_url
    assert_equal "Doctor was successfully deleted.", flash[:notice]
  end

  test "should destroy doctor as JSON" do
    assert_difference("Doctor.count", -1) do
      delete doctor_url(@independent_doctor), as: :json
    end

    assert_response :no_content
  end

  test "should not destroy doctor with appointments" do
    # Create appointment for doctor
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    assert_no_difference("Doctor.count") do
      delete doctor_url(@doctor)
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Cannot delete doctor with scheduled appointments"
  end

  # Custom endpoints tests
  test "should get doctor appointments" do
    # Create appointments for testing
    appointment1 = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    appointment2 = Appointment.create!(
      doctor: @doctor,
      patient: @patient2,
      appointment_date: 2.weeks.from_now,
      status: "scheduled"
    )

    get doctor_appointments_url(@doctor)
    assert_response :success
    assert_includes @response.body, "Appointments"
  end

  test "should get doctor appointments as JSON" do
    appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    get doctor_appointments_url(@doctor), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
    assert_equal appointment.id, json_response.first["id"]
  end

  test "should filter doctor appointments by status" do
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    Appointment.create!(
      doctor: @doctor,
      patient: @patient2,
      appointment_date: 1.day.ago,
      status: "completed"
    )

    get doctor_appointments_url(@doctor), params: { status: "scheduled" }
    assert_response :success
  end

  test "should get doctor schedule" do
    get doctor_schedule_url(@doctor), params: { date: 1.week.from_now.to_date }
    assert_response :success
  end

  test "should get doctor schedule as JSON" do
    get doctor_schedule_url(@doctor), params: { date: 1.week.from_now.to_date }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("date")
    assert json_response.key?("appointments")
    assert json_response.key?("available_slots")
  end

  test "should get doctor availability" do
    get doctor_availability_url(@doctor), params: {
      start_date: Date.current,
      end_date: 1.week.from_now.to_date
    }
    assert_response :success
  end

  test "should get doctor availability as JSON" do
    get doctor_availability_url(@doctor), params: {
      start_date: Date.current,
      end_date: 1.week.from_now.to_date
    }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("available_dates")
  end

  test "should get doctor patients" do
    # Create appointments to establish patient relationships
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.ago,
      status: "completed"
    )

    get doctor_patients_url(@doctor)
    assert_response :success
    assert_includes @response.body, @patient.full_name
  end

  test "should get doctor patients as JSON" do
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.ago,
      status: "completed"
    )

    get doctor_patients_url(@doctor), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
  end

  test "should get doctor statistics" do
    get doctor_statistics_url(@doctor)
    assert_response :success
    assert_includes @response.body, "Statistics"
  end

  test "should get doctor statistics as JSON" do
    get doctor_statistics_url(@doctor), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("total_appointments")
    assert json_response.key?("total_patients")
    assert json_response.key?("upcoming_appointments")
  end

  # Search and filtering tests
  test "should search doctors by multiple criteria" do
    get search_doctors_url, params: {
      specialization: "Cardiology",
      hospital_id: @hospital.id,
      available_date: 1.week.from_now.to_date
    }
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  test "should get doctors by experience level" do
    get doctors_url, params: { experience: "senior" }
    assert_response :success
  end

  test "should get available doctors for emergency" do
    get available_doctors_url, params: { emergency: true }
    assert_response :success
  end

  test "should get doctors accepting new patients" do
    get doctors_url, params: { accepting_patients: true }
    assert_response :success
  end

  # Appointment scheduling tests
  test "should get doctor available slots" do
    get doctor_available_slots_url(@doctor), params: { date: 1.week.from_now.to_date }
    assert_response :success
  end

  test "should get doctor available slots as JSON" do
    get doctor_available_slots_url(@doctor), params: { date: 1.week.from_now.to_date }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("available_slots")
    assert json_response["available_slots"].is_a?(Array)
  end

  test "should book appointment with doctor" do
    assert_difference("Appointment.count") do
      post doctor_book_appointment_url(@doctor), params: {
        appointment: {
          patient_id: @patient.id,
          appointment_date: 1.week.from_now,
          status: "scheduled"
        }
      }
    end

    assert_response :created
    assert_equal "Appointment successfully booked.", flash[:notice]
  end

  test "should not book overlapping appointment" do
    # Create existing appointment
    existing_time = 1.week.from_now.change(hour: 14, min: 0)
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: existing_time,
      status: "scheduled"
    )

    # Try to book overlapping appointment
    assert_no_difference("Appointment.count") do
      post doctor_book_appointment_url(@doctor), params: {
        appointment: {
          patient_id: @patient2.id,
          appointment_date: existing_time, # Same time
          status: "scheduled"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Time slot is not available"
  end

  # Error handling tests
  test "should handle invalid doctor ID gracefully" do
    get doctor_url(id: "invalid")
    assert_response :not_found
  end

  test "should handle server errors gracefully" do
    Doctor.stub :find, -> { raise StandardError.new("Test error") } do
      get doctor_url(@doctor)
      assert_response :internal_server_error
    end
  end

  # Pagination tests
  test "should paginate doctors list" do
    # Create more doctors to test pagination
    15.times do |i|
      Doctor.create!(
        first_name: "Dr. Test#{i}",
        last_name: "Doctor#{i}",
        email: "doctor#{i}@test.com",
        specialization: "Test Specialty"
      )
    end

    get doctors_url, params: { page: 2, per_page: 10 }
    assert_response :success
  end

  # Sorting tests
  test "should sort doctors by name" do
    get doctors_url, params: { sort: "last_name", direction: "asc" }
    assert_response :success
  end

  test "should sort doctors by specialization" do
    get doctors_url, params: { sort: "specialization", direction: "desc" }
    assert_response :success
  end

  # Location-based tests
  test "should get nearby doctors" do
    get nearby_doctors_url, params: {
      latitude: 37.7749,
      longitude: -122.4194,
      radius: 10,
      specialization: "Cardiology"
    }
    assert_response :success
  end

  test "should get doctors by facility type" do
    get doctors_url, params: { facility_type: "hospital" }
    assert_response :success
    assert_includes @response.body, @doctor.full_name
    assert_not_includes @response.body, @clinic_doctor.full_name
  end
end
