require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
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

    # Create test appointments
    @scheduled_appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: 1.week.from_now.change(hour: 14, min: 0), # 2 PM on a weekday
      status: "scheduled",
      duration_minutes: 30,
      appointment_type: "routine"
    )

    @completed_appointment = Appointment.create!(
      doctor: @family_doctor,
      patient: @patient,
      appointment_date: 1.day.ago.change(hour: 14, min: 0), # 2 PM yesterday
      status: "completed",
      duration_minutes: 30,
      appointment_type: "routine"
    )

    @emergency_appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient2,
      appointment_date: 2.days.from_now.change(hour: 9, min: 0), # 9 AM on a weekday
      status: "scheduled",
      duration_minutes: 30,
      appointment_type: "emergency"
    )
  end

  # INDEX action tests
  test "should get index" do
    get appointments_url
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.id.to_s
    assert_includes @response.body, @completed_appointment.id.to_s
    assert_includes @response.body, @emergency_appointment.id.to_s
  end

  test "should get index as JSON" do
    get appointments_url, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 3, json_response.length
    assert_includes json_response.map { |a| a["id"] }, @scheduled_appointment.id
  end

  test "should filter appointments by status" do
    get appointments_url, params: { status: "scheduled" }
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.id.to_s
    assert_not_includes @response.body, @completed_appointment.id.to_s
  end

  test "should filter appointments by doctor" do
    get appointments_url, params: { doctor_id: @doctor.id }
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.id.to_s
    assert_not_includes @response.body, @completed_appointment.id.to_s
  end

  test "should filter appointments by patient" do
    get appointments_url, params: { patient_id: @patient.id }
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.id.to_s
    assert_includes @response.body, @completed_appointment.id.to_s
    assert_not_includes @response.body, @emergency_appointment.id.to_s
  end

  test "should filter appointments by date range" do
    get appointments_url, params: {
      start_date: Date.current,
      end_date: 2.weeks.from_now.to_date
    }
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.id.to_s
    assert_not_includes @response.body, @completed_appointment.id.to_s
  end

  test "should get today's appointments" do
    # Create appointment for today
    today_appointment = Appointment.create!(
      doctor: @doctor,
      patient: @patient,
      appointment_date: Date.current.change(hour: 15, min: 30),
      status: "scheduled",
      duration_minutes: 30,
      appointment_type: "routine"
    )

    get appointments_url, params: { date: Date.current }
    assert_response :success
    assert_includes @response.body, today_appointment.id.to_s
  end

  # SHOW action tests
  test "should show appointment" do
    get appointment_url(@scheduled_appointment)
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.doctor.full_name
    assert_includes @response.body, @scheduled_appointment.patient.full_name
  end

  test "should show appointment as JSON" do
    get appointment_url(@scheduled_appointment), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal @scheduled_appointment.id, json_response["id"]
    assert_equal @scheduled_appointment.status, json_response["status"]
  end

  test "should show appointment details" do
    get appointment_url(@scheduled_appointment)
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.appointment_date.strftime("%B %d, %Y")
    assert_includes @response.body, @scheduled_appointment.status.titleize
  end

  test "should return 404 for non-existent appointment" do
    get appointment_url(id: 99999)
    assert_response :not_found
  end

  # NEW action tests
  test "should get new" do
    get new_appointment_url
    assert_response :success
    assert_includes @response.body, "New Appointment"
  end

  test "should get new with doctor preselected" do
    get new_appointment_url, params: { doctor_id: @doctor.id }
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  test "should get new with patient preselected" do
    get new_appointment_url, params: { patient_id: @patient.id }
    assert_response :success
    assert_includes @response.body, @patient.full_name
  end

  test "should get new with date preselected" do
    selected_date = 1.week.from_now.to_date
    get new_appointment_url, params: { date: selected_date }
    assert_response :success
    assert_includes @response.body, selected_date.strftime("%B %d, %Y")
  end

  # CREATE action tests
  test "should create appointment" do
    assert_difference("Appointment.count") do
      post appointments_url, params: {
        appointment: {
          doctor_id: @family_doctor.id,
          patient_id: @patient2.id,
          appointment_date: 2.weeks.from_now.change(hour: 10, min: 0),
          status: "scheduled"
        }
      }
    end

    assert_redirected_to appointment_url(Appointment.last)
    assert_equal "Appointment was successfully scheduled.", flash[:notice]
  end

  test "should create appointment as JSON" do
    assert_difference("Appointment.count") do
      post appointments_url, params: {
        appointment: {
          doctor_id: @family_doctor.id,
          patient_id: @patient2.id,
          appointment_date: 2.weeks.from_now.change(hour: 11, min: 0),
          status: "scheduled"
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(@response.body)
    assert_equal @family_doctor.id, json_response["doctor_id"]
    assert_equal @patient2.id, json_response["patient_id"]
  end

  test "should create emergency appointment" do
    assert_difference("Appointment.count") do
      post appointments_url, params: {
        appointment: {
          doctor_id: @doctor.id,
          patient_id: @patient.id,
          appointment_date: 1.hour.from_now,
          status: "scheduled"
        }
      }
    end

    created_appointment = Appointment.last
    assert created_appointment.is_upcoming?
  end

  test "should not create appointment with invalid data" do
    assert_no_difference("Appointment.count") do
      post appointments_url, params: {
        appointment: {
          doctor_id: nil, # Invalid - missing doctor
          patient_id: @patient.id,
          appointment_date: "", # Invalid - blank date
          status: "invalid_status" # Invalid status
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Doctor must exist"
  end

  test "should not create overlapping appointment" do
    existing_time = @scheduled_appointment.appointment_date

    assert_no_difference("Appointment.count") do
      post appointments_url, params: {
        appointment: {
          doctor_id: @doctor.id, # Same doctor
          patient_id: @patient2.id,
          appointment_date: existing_time, # Same time
          status: "scheduled"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Time slot is not available"
  end

  test "should not create appointment in the past" do
    assert_no_difference("Appointment.count") do
      post appointments_url, params: {
        appointment: {
          doctor_id: @doctor.id,
          patient_id: @patient.id,
          appointment_date: 1.day.ago, # Past date
          status: "scheduled"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "cannot be in the past"
  end

  # EDIT action tests
  test "should get edit" do
    get edit_appointment_url(@scheduled_appointment)
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.doctor.full_name
    assert_includes @response.body, @scheduled_appointment.patient.full_name
  end

  test "should not edit completed appointment" do
    get edit_appointment_url(@completed_appointment)
    assert_response :unprocessable_entity
    assert_includes @response.body, "Cannot edit completed appointment"
  end

  # UPDATE action tests
  test "should update appointment" do
    new_time = 2.weeks.from_now.change(hour: 15, min: 30)

    patch appointment_url(@scheduled_appointment), params: {
      appointment: {
        appointment_date: new_time,
        status: "confirmed"
      }
    }

    assert_redirected_to appointment_url(@scheduled_appointment)
    assert_equal "Appointment was successfully updated.", flash[:notice]
    @scheduled_appointment.reload
    assert_equal "confirmed", @scheduled_appointment.status
  end

  test "should update appointment as JSON" do
    patch appointment_url(@scheduled_appointment), params: {
      appointment: {
        status: "confirmed"
      }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(@response.body)
    assert_equal "confirmed", json_response["status"]
  end

  test "should reschedule appointment" do
    new_time = 3.weeks.from_now.change(hour: 16, min: 0)

    patch appointment_url(@scheduled_appointment), params: {
      appointment: {
        appointment_date: new_time
      }
    }

    assert_redirected_to appointment_url(@scheduled_appointment)
    @scheduled_appointment.reload
    assert_equal new_time.to_i, @scheduled_appointment.appointment_date.to_i
  end

  test "should not update appointment with conflicting time" do
    # Try to reschedule to overlap with emergency appointment
    conflicting_time = @emergency_appointment.appointment_date

    patch appointment_url(@scheduled_appointment), params: {
      appointment: {
        appointment_date: conflicting_time,
        doctor_id: @emergency_appointment.doctor_id
      }
    }

    assert_response :unprocessable_entity
    assert_includes @response.body, "Time slot is not available"
  end

  test "should not update completed appointment" do
    patch appointment_url(@completed_appointment), params: {
      appointment: {
        status: "cancelled"
      }
    }

    assert_response :unprocessable_entity
    assert_includes @response.body, "Cannot modify completed appointment"
  end

  # DESTROY action tests
  test "should destroy scheduled appointment" do
    assert_difference("Appointment.count", -1) do
      delete appointment_url(@scheduled_appointment)
    end

    assert_redirected_to appointments_url
    assert_equal "Appointment was successfully cancelled.", flash[:notice]
  end

  test "should destroy appointment as JSON" do
    assert_difference("Appointment.count", -1) do
      delete appointment_url(@scheduled_appointment), as: :json
    end

    assert_response :no_content
  end

  test "should not destroy completed appointment" do
    assert_no_difference("Appointment.count") do
      delete appointment_url(@completed_appointment)
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Cannot cancel completed appointment"
  end

  # Custom endpoints tests
  test "should confirm appointment" do
    patch confirm_appointment_url(@scheduled_appointment)
    assert_response :success

    @scheduled_appointment.reload
    assert_equal "confirmed", @scheduled_appointment.status
    assert_equal "Appointment confirmed.", flash[:notice]
  end

  test "should confirm appointment as JSON" do
    patch confirm_appointment_url(@scheduled_appointment), as: :json
    assert_response :ok

    json_response = JSON.parse(@response.body)
    assert_equal "confirmed", json_response["status"]
  end

  test "should cancel appointment" do
    patch cancel_appointment_url(@scheduled_appointment)
    assert_response :success

    @scheduled_appointment.reload
    assert_equal "cancelled", @scheduled_appointment.status
    assert_equal "Appointment cancelled.", flash[:notice]
  end

  test "should cancel appointment as JSON" do
    patch cancel_appointment_url(@scheduled_appointment), as: :json
    assert_response :ok

    json_response = JSON.parse(@response.body)
    assert_equal "cancelled", json_response["status"]
  end

  test "should complete appointment" do
    patch complete_appointment_url(@scheduled_appointment)
    assert_response :success

    @scheduled_appointment.reload
    assert_equal "completed", @scheduled_appointment.status
    assert_equal "Appointment completed.", flash[:notice]
  end

  test "should mark appointment as no show" do
    patch no_show_appointment_url(@scheduled_appointment)
    assert_response :success

    @scheduled_appointment.reload
    assert_equal "no_show", @scheduled_appointment.status
  end

  test "should reschedule appointment to new time" do
    new_time = 2.weeks.from_now.change(hour: 16, min: 30)

    patch reschedule_appointment_url(@scheduled_appointment), params: {
      new_appointment_date: new_time
    }

    assert_response :success
    @scheduled_appointment.reload
    assert_equal new_time.to_i, @scheduled_appointment.appointment_date.to_i
    assert_equal "Appointment rescheduled.", flash[:notice]
  end

  test "should not reschedule to conflicting time" do
    conflicting_time = @emergency_appointment.appointment_date

    patch reschedule_appointment_url(@scheduled_appointment), params: {
      new_appointment_date: conflicting_time
    }

    assert_response :unprocessable_entity
    assert_includes @response.body, "Time slot is not available"
  end

  # Scheduling and availability tests
  test "should get available time slots" do
    get available_slots_url, params: {
      doctor_id: @doctor.id,
      date: 1.week.from_now.to_date
    }
    assert_response :success
  end

  test "should get available time slots as JSON" do
    get available_slots_url, params: {
      doctor_id: @doctor.id,
      date: 1.week.from_now.to_date
    }, as: :json

    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("available_slots")
    assert json_response["available_slots"].is_a?(Array)
  end

  test "should check appointment conflicts" do
    get check_conflicts_url, params: {
      doctor_id: @doctor.id,
      appointment_date: @scheduled_appointment.appointment_date
    }
    assert_response :success
  end

  test "should check appointment conflicts as JSON" do
    get check_conflicts_url, params: {
      doctor_id: @doctor.id,
      appointment_date: @scheduled_appointment.appointment_date
    }, as: :json

    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("has_conflict")
    assert json_response["has_conflict"] == true
  end

  test "should get appointment statistics" do
    get appointment_statistics_url
    assert_response :success
    assert_includes @response.body, "Statistics"
  end

  test "should get appointment statistics as JSON" do
    get appointment_statistics_url, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("total_appointments")
    assert json_response.key?("by_status")
    assert json_response.key?("upcoming_count")
  end

  # Calendar and scheduling views
  test "should get calendar view" do
    get calendar_appointments_url, params: {
      year: Date.current.year,
      month: Date.current.month
    }
    assert_response :success
  end

  test "should get calendar view as JSON" do
    get calendar_appointments_url, params: {
      year: Date.current.year,
      month: Date.current.month
    }, as: :json

    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("appointments_by_date")
  end

  test "should get daily schedule" do
    get daily_schedule_url, params: { date: Date.current }
    assert_response :success
  end

  test "should get weekly schedule" do
    get weekly_schedule_url, params: {
      start_date: Date.current.beginning_of_week
    }
    assert_response :success
  end

  # Reminder and notification tests
  test "should send appointment reminder" do
    post send_reminder_url(@scheduled_appointment)
    assert_response :success
    assert_equal "Reminder sent.", flash[:notice]
  end

  test "should get upcoming appointments needing reminders" do
    get upcoming_reminders_url
    assert_response :success
  end

  # Wait time and queue management
  test "should get current wait times" do
    get wait_times_url, params: { doctor_id: @doctor.id }
    assert_response :success
  end

  test "should get current wait times as JSON" do
    get wait_times_url, params: { doctor_id: @doctor.id }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("estimated_wait_time")
  end

  test "should get appointment queue" do
    get appointment_queue_url, params: { doctor_id: @doctor.id }
    assert_response :success
  end

  # Search and filtering tests
  test "should search appointments by patient name" do
    get search_appointments_url, params: { patient_name: "John" }
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.id.to_s
  end

  test "should search appointments by doctor name" do
    get search_appointments_url, params: { doctor_name: "Smith" }
    assert_response :success
    assert_includes @response.body, @scheduled_appointment.id.to_s
  end

  test "should filter overdue appointments" do
    get overdue_appointments_url
    assert_response :success
  end

  test "should filter emergency appointments" do
    get emergency_appointments_url
    assert_response :success
  end

  # Reporting tests
  test "should get appointment reports" do
    get appointment_reports_url, params: {
      start_date: 1.month.ago,
      end_date: Date.current
    }
    assert_response :success
  end

  test "should export appointments" do
    get export_appointments_url, params: {
      format: "csv",
      start_date: 1.month.ago,
      end_date: Date.current
    }
    assert_response :success
  end

  # Error handling tests
  test "should handle invalid appointment ID gracefully" do
    get appointment_url(id: "invalid")
    assert_response :not_found
  end

  test "should handle server errors gracefully" do
    Appointment.stub :find, -> { raise StandardError.new("Test error") } do
      get appointment_url(@scheduled_appointment)
      assert_response :internal_server_error
    end
  end

  # Pagination tests
  test "should paginate appointments list" do
    # Create more appointments to test pagination
    15.times do |i|
      Appointment.create!(
        doctor: @doctor,
        patient: @patient,
        appointment_date: (i + 1).days.from_now.change(hour: 9 + i % 8, min: 0),
        status: "scheduled"
      )
    end

    get appointments_url, params: { page: 2, per_page: 10 }
    assert_response :success
  end

  # Sorting tests
  test "should sort appointments by date" do
    get appointments_url, params: { sort: "appointment_date", direction: "asc" }
    assert_response :success
  end

  test "should sort appointments by patient name" do
    get appointments_url, params: { sort: "patient_name", direction: "desc" }
    assert_response :success
  end

  test "should sort appointments by doctor name" do
    get appointments_url, params: { sort: "doctor_name", direction: "asc" }
    assert_response :success
  end

  # Bulk operations tests
  test "should bulk cancel appointments" do
    appointment_ids = [ @scheduled_appointment.id, @emergency_appointment.id ]

    patch bulk_cancel_appointments_url, params: {
      appointment_ids: appointment_ids
    }

    assert_response :success
    assert_equal "Appointments cancelled.", flash[:notice]

    [ @scheduled_appointment, @emergency_appointment ].each(&:reload)
    assert_equal "cancelled", @scheduled_appointment.status
    assert_equal "cancelled", @emergency_appointment.status
  end

  test "should bulk reschedule appointments" do
    appointment_ids = [ @scheduled_appointment.id ]
    new_date = 3.weeks.from_now.to_date

    patch bulk_reschedule_appointments_url, params: {
      appointment_ids: appointment_ids,
      new_date: new_date
    }

    assert_response :success
    assert_equal "Appointments rescheduled.", flash[:notice]
  end
end
