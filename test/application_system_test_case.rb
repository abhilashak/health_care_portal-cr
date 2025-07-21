require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Healthcare application specific system test helpers

  # Setup method for healthcare system tests
  def setup
    super
    # Any healthcare-specific setup can go here
  end

  # Helper to wait for healthcare forms to load
  def wait_for_healthcare_form
    assert_selector "form", wait: 5
  end

  # Helper to fill in patient information forms
  def fill_patient_form(first_name:, last_name:, email:, phone:)
    fill_in "First Name", with: first_name
    fill_in "Last Name", with: last_name
    fill_in "Email", with: email
    fill_in "Phone", with: phone
  end

  # Helper to fill in doctor information forms
  def fill_doctor_form(first_name:, last_name:, email:, phone:, specialization:)
    fill_in "First Name", with: first_name
    fill_in "Last Name", with: last_name
    fill_in "Email", with: email
    fill_in "Phone", with: phone
    fill_in "Specialization", with: specialization
  end

  # Helper to select date and time for appointments
  def select_appointment_datetime(date:, time:)
    fill_in "Date", with: date.strftime("%Y-%m-%d")
    fill_in "Time", with: time.strftime("%H:%M")
  end

  # Helper to assert successful form submission
  def assert_successful_submission(message = "Successfully")
    assert_text message
    assert_no_text "error"
  end

  # Helper to assert healthcare data is properly displayed
  def assert_healthcare_data_visible(data_type:, value:)
    case data_type
    when :patient_name
      assert_text value
    when :doctor_name
      assert_text value
    when :appointment_date
      assert_text value.strftime("%B %d, %Y")
    when :appointment_time
      assert_text value.strftime("%I:%M %p")
    end
  end

  # Helper to navigate to different sections of the healthcare portal
  def navigate_to(section)
    case section
    when :dashboard
      click_link "Dashboard"
    when :patients
      click_link "Patients"
    when :doctors
      click_link "Doctors"
    when :appointments
      click_link "Appointments"
    when :hospitals
      click_link "Hospitals"
    when :clinics
      click_link "Clinics"
    end
  end
end
