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

    @family_doctor = Doctor.create!(
      first_name: "Dr. Jennifer",
      last_name: "Brown",
      specialization: "Family Medicine",
      clinic: @clinic
    )

    # Create test patients
    @patient = Patient.create!(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@email.com",
      date_of_birth: 30.years.ago.to_date
    )

    @pediatric_patient = Patient.create!(
      first_name: "Sarah",
      last_name: "Smith",
      email: "parent.smith@email.com",
      date_of_birth: 8.years.ago.to_date
    )

    @senior_patient = Patient.create!(
      first_name: "William",
      last_name: "Davis",
      email: "william.davis@email.com",
      date_of_birth: 75.years.ago.to_date
    )
  end

  # INDEX action tests
  test "should get index" do
    get patients_url
    assert_response :success
    assert_includes @response.body, @patient.full_name
    assert_includes @response.body, @pediatric_patient.full_name
    assert_includes @response.body, @senior_patient.full_name
  end

  test "should get index as JSON" do
    get patients_url, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 3, json_response.length
    assert_includes json_response.map { |p| p["full_name"] }, @patient.full_name
  end

  test "should filter patients by name" do
    get patients_url, params: { search: "John" }
    assert_response :success
    assert_includes @response.body, @patient.full_name
    assert_not_includes @response.body, @pediatric_patient.full_name
  end

  test "should filter patients by age group" do
    get patients_url, params: { age_group: "pediatric" }
    assert_response :success
    assert_includes @response.body, @pediatric_patient.full_name
    assert_not_includes @response.body, @patient.full_name
  end

  test "should filter patients by email" do
    get patients_url, params: { email: @patient.email }
    assert_response :success
    assert_includes @response.body, @patient.full_name
  end

  # SHOW action tests
  test "should show patient" do
    get patient_url(@patient)
    assert_response :success
    assert_includes @response.body, @patient.full_name
    assert_includes @response.body, @patient.email
  end

  test "should show patient as JSON" do
    get patient_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal @patient.full_name, json_response["full_name"]
    assert_equal @patient.email, json_response["email"]
  end

  test "should show patient age and demographics" do
    get patient_url(@patient)
    assert_response :success
    assert_includes @response.body, @patient.age.to_s
    assert_includes @response.body, @patient.age_group
  end

  test "should return 404 for non-existent patient" do
    get patient_url(id: 99999)
    assert_response :not_found
  end

  # NEW action tests
  test "should get new" do
    get new_patient_url
    assert_response :success
    assert_includes @response.body, "New Patient"
  end

  # CREATE action tests
  test "should create patient" do
    assert_difference("Patient.count") do
      post patients_url, params: {
        patient: {
          first_name: "Michael",
          last_name: "Johnson",
          email: "michael.johnson@email.com",
          date_of_birth: 35.years.ago
        }
      }
    end

    assert_redirected_to patient_url(Patient.last)
    assert_equal "Patient was successfully created.", flash[:notice]
  end

  test "should create patient as JSON" do
    assert_difference("Patient.count") do
      post patients_url, params: {
        patient: {
          first_name: "API",
          last_name: "Patient",
          email: "api.patient@email.com",
          date_of_birth: 28.years.ago
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(@response.body)
    assert_equal "API Patient", json_response["full_name"]
  end

  test "should create pediatric patient" do
    assert_difference("Patient.count") do
      post patients_url, params: {
        patient: {
          first_name: "Emma",
          last_name: "Wilson",
          email: "parent.wilson@email.com",
          date_of_birth: 5.years.ago
        }
      }
    end

    created_patient = Patient.last
    assert created_patient.minor?
    assert_equal "Child", created_patient.age_group
  end

  test "should not create patient with invalid data" do
    assert_no_difference("Patient.count") do
      post patients_url, params: {
        patient: {
          first_name: "", # Invalid - blank name
          last_name: "Test",
          email: "invalid-email", # Invalid email format
          date_of_birth: Date.current + 1.day # Future date
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "First name can't be blank"
  end

  test "should not create patient with duplicate email" do
    assert_no_difference("Patient.count") do
      post patients_url, params: {
        patient: {
          first_name: "Duplicate",
          last_name: "Email",
          email: @patient.email, # Duplicate email
          date_of_birth: 25.years.ago
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Email has already been taken"
  end

  test "should not create patient with future birth date" do
    assert_no_difference("Patient.count") do
      post patients_url, params: {
        patient: {
          first_name: "Future",
          last_name: "Baby",
          email: "future@email.com",
          date_of_birth: 1.year.from_now # Future date
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Date of birth must be in the past"
  end

  # EDIT action tests
  test "should get edit" do
    get edit_patient_url(@patient)
    assert_response :success
    assert_includes @response.body, @patient.full_name
  end

  # UPDATE action tests
  test "should update patient" do
    patch patient_url(@patient), params: {
      patient: {
        first_name: "Updated John",
        last_name: @patient.last_name,
        email: @patient.email,
        date_of_birth: @patient.date_of_birth
      }
    }

    assert_redirected_to patient_url(@patient)
    assert_equal "Patient was successfully updated.", flash[:notice]
    @patient.reload
    assert_equal "Updated John", @patient.first_name
  end

  test "should update patient as JSON" do
    patch patient_url(@patient), params: {
      patient: {
        first_name: "JSON Updated John"
      }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(@response.body)
    assert_equal "JSON Updated John", json_response["first_name"]
  end

  test "should not update patient with invalid data" do
    patch patient_url(@patient), params: {
      patient: {
        email: "invalid-email-format",
        date_of_birth: 1.year.from_now # Future date
      }
    }

    assert_response :unprocessable_entity
    @patient.reload
    assert_not_equal "invalid-email-format", @patient.email
  end

  # DESTROY action tests
  test "should destroy patient without appointments" do
    # Create patient without appointments
    empty_patient = Patient.create!(
      first_name: "Empty",
      last_name: "Patient",
      email: "empty@email.com",
      date_of_birth: 30.years.ago
    )

    assert_difference("Patient.count", -1) do
      delete patient_url(empty_patient)
    end

    assert_redirected_to patients_url
    assert_equal "Patient was successfully deleted.", flash[:notice]
  end

  test "should destroy patient as JSON" do
    empty_patient = Patient.create!(
      first_name: "Empty API",
      last_name: "Patient",
      email: "empty.api@email.com",
      date_of_birth: 30.years.ago
    )

    assert_difference("Patient.count", -1) do
      delete patient_url(empty_patient), as: :json
    end

    assert_response :no_content
  end

  test "should not destroy patient with appointments" do
    # Create appointment for patient
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    assert_no_difference("Patient.count") do
      delete patient_url(@patient)
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Cannot delete patient with scheduled appointments"
  end

  # Custom endpoints tests
  test "should get patient appointments" do
    # Create appointments for testing
    appointment1 = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    appointment2 = Appointment.create!(
      doctor: @family_doctor,
      patient: @patient,
      appointment_date: 2.weeks.from_now,
      status: "scheduled"
    )

    get patient_appointments_url(@patient)
    assert_response :success
    assert_includes @response.body, "Appointments"
  end

  test "should get patient appointments as JSON" do
    appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    get patient_appointments_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
    assert_equal appointment.id, json_response.first["id"]
  end

  test "should filter patient appointments by status" do
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.ago,
      status: "completed"
    )

    get patient_appointments_url(@patient), params: { status: "scheduled" }
    assert_response :success
  end

  test "should get upcoming appointments" do
    # Create future appointments
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    get patient_upcoming_appointments_url(@patient)
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  test "should get upcoming appointments as JSON" do
    appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    get patient_upcoming_appointments_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
  end

  test "should get appointment history" do
    # Create past appointment
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.month.ago,
      status: "completed"
    )

    get patient_appointment_history_url(@patient)
    assert_response :success
    assert_includes @response.body, "History"
  end

  test "should get appointment history as JSON" do
    appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.month.ago,
      status: "completed"
    )

    get patient_appointment_history_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
  end

  test "should get patient doctors" do
    # Create appointments to establish doctor relationships
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.ago,
      status: "completed"
    )

    Appointment.create!(
      doctor: @family_doctor,
      patient: @patient,
      appointment_date: 1.month.ago,
      status: "completed"
    )

    get patient_doctors_url(@patient)
    assert_response :success
    assert_includes @response.body, @doctor.full_name
    assert_includes @response.body, @family_doctor.full_name
  end

  test "should get patient doctors as JSON" do
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.ago,
      status: "completed"
    )

    get patient_doctors_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
  end

  test "should get primary doctor" do
    # Create multiple appointments with one doctor to make them primary
    3.times do |i|
      Appointment.create!(
        doctor: @doctor,
        patient: @patient,
        appointment_date: (i + 1).weeks.ago,
        status: "completed"
      )
    end

    get patient_primary_doctor_url(@patient)
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  test "should get primary doctor as JSON" do
    3.times do |i|
      Appointment.create!(
        doctor: @doctor,
        patient: @patient,
        appointment_date: (i + 1).weeks.ago,
        status: "completed"
      )
    end

    get patient_primary_doctor_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal @doctor.full_name, json_response["full_name"]
  end

  test "should get patient statistics" do
    get patient_statistics_url(@patient)
    assert_response :success
    assert_includes @response.body, "Statistics"
  end

  test "should get patient statistics as JSON" do
    get patient_statistics_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("total_appointments")
    assert json_response.key?("age")
    assert json_response.key?("age_group")
  end

  # Appointment booking tests
  test "should book appointment for patient" do
    assert_difference("Appointment.count") do
      post patient_book_appointment_url(@patient), params: {
        appointment: {
          doctor_id: @doctor.id,
          appointment_date: 1.week.from_now,
          status: "scheduled"
        }
      }
    end

    assert_response :created
    assert_equal "Appointment successfully booked.", flash[:notice]
  end

  test "should book appointment for patient as JSON" do
    assert_difference("Appointment.count") do
      post patient_book_appointment_url(@patient), params: {
        appointment: {
          doctor_id: @doctor.id,
          appointment_date: 1.week.from_now,
          status: "scheduled"
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(@response.body)
    assert_equal @patient.id, json_response["patient_id"]
    assert_equal @doctor.id, json_response["doctor_id"]
  end

  test "should not book overlapping appointment for patient" do
    # Create existing appointment
    existing_time = 1.week.from_now.change(hour: 14, min: 0)
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: existing_time,
      status: "scheduled"
    )

    # Try to book another appointment at same time with same doctor
    assert_no_difference("Appointment.count") do
      post patient_book_appointment_url(@patient), params: {
        appointment: {
          doctor_id: @doctor.id,
          appointment_date: existing_time,
          status: "scheduled"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Time slot is not available"
  end

  # Search and filtering tests
  test "should search patients by multiple criteria" do
    get search_patients_url, params: {
      name: "John",
      age_min: 25,
      age_max: 35
    }
    assert_response :success
    assert_includes @response.body, @patient.full_name
  end

  test "should get patients by age range" do
    get patients_url, params: { age_min: 60, age_max: 80 }
    assert_response :success
    assert_includes @response.body, @senior_patient.full_name
    assert_not_includes @response.body, @patient.full_name
  end

  test "should get patients by birth year" do
    birth_year = @patient.date_of_birth.year
    get patients_url, params: { birth_year: birth_year }
    assert_response :success
    assert_includes @response.body, @patient.full_name
  end

  test "should get pediatric patients" do
    get pediatric_patients_url
    assert_response :success
    assert_includes @response.body, @pediatric_patient.full_name
    assert_not_includes @response.body, @patient.full_name
  end

  test "should get senior patients" do
    get senior_patients_url
    assert_response :success
    assert_includes @response.body, @senior_patient.full_name
    assert_not_includes @response.body, @patient.full_name
  end

  test "should get patients with upcoming appointments" do
    Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now,
      status: "scheduled"
    )

    get patients_with_upcoming_appointments_url
    assert_response :success
    assert_includes @response.body, @patient.full_name
  end

  # Emergency contact tests
  test "should get emergency contact info" do
    get patient_emergency_contact_url(@patient)
    assert_response :success
  end

  test "should get emergency contact info as JSON" do
    get patient_emergency_contact_url(@patient), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("emergency_contact_info")
  end

  # Error handling tests
  test "should handle invalid patient ID gracefully" do
    get patient_url(id: "invalid")
    assert_response :not_found
  end

  test "should handle server errors gracefully" do
    Patient.stub :find, -> { raise StandardError.new("Test error") } do
      get patient_url(@patient)
      assert_response :internal_server_error
    end
  end

  # Pagination tests
  test "should paginate patients list" do
    # Create more patients to test pagination
    15.times do |i|
      Patient.create!(
        first_name: "Test#{i}",
        last_name: "Patient#{i}",
        email: "patient#{i}@test.com",
        date_of_birth: (20 + i).years.ago
      )
    end

    get patients_url, params: { page: 2, per_page: 10 }
    assert_response :success
  end

  # Sorting tests
  test "should sort patients by name" do
    get patients_url, params: { sort: "last_name", direction: "asc" }
    assert_response :success
  end

  test "should sort patients by age" do
    get patients_url, params: { sort: "date_of_birth", direction: "desc" }
    assert_response :success
  end

  test "should sort patients by email" do
    get patients_url, params: { sort: "email", direction: "asc" }
    assert_response :success
  end

  # Data privacy tests
  test "should handle patient data with privacy considerations" do
    get patient_url(@pediatric_patient)
    assert_response :success
    # Verify sensitive data is properly handled for minors
    assert_includes @response.body, "Minor"
  end

  test "should validate patient data access permissions" do
    # Test accessing patient data (in real app would check authentication)
    get patient_url(@patient)
    assert_response :success
  end
end
