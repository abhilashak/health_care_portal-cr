module HealthcareTestHelper
  # Test data generators for healthcare entities

  # Generate sample hospital data
  def sample_hospital_attributes
    {
      name: "General Hospital #{rand(100..999)}",
      address: "#{rand(100..9999)} Medical Center Dr",
      city: "Healthcare City",
      state: "CA",
      zip_code: "9#{rand(1000..9999)}",
      phone: valid_phone_number,
      email: valid_email("hospital"),
      established_date: Date.current - rand(1..50).years
    }
  end

  # Generate sample clinic data
  def sample_clinic_attributes
    {
      name: "#{[ 'Family', 'Pediatric', 'Internal', 'Urgent' ].sample} Clinic #{rand(100..999)}",
      address: "#{rand(100..9999)} Clinic Ave",
      city: "Healthcare City",
      state: "CA",
      zip_code: "9#{rand(1000..9999)}",
      phone: valid_phone_number,
      email: valid_email("clinic"),
      established_date: Date.current - rand(1..30).years
    }
  end

  # Generate sample doctor data
  def sample_doctor_attributes
    {
      first_name: [ "Dr. John", "Dr. Sarah", "Dr. Michael", "Dr. Emily" ].sample,
      last_name: [ "Smith", "Johnson", "Williams", "Brown", "Davis" ].sample,
      email: valid_email("doctor"),
      phone: valid_phone_number,
      specialization: [ "Cardiology", "Pediatrics", "Internal Medicine", "Emergency Medicine", "Family Medicine" ].sample,
      license_number: "MD#{rand(100000..999999)}",
      years_of_experience: rand(1..40)
    }
  end

  # Generate sample patient data
  def sample_patient_attributes
    {
      first_name: [ "John", "Sarah", "Michael", "Emily", "David", "Lisa" ].sample,
      last_name: [ "Smith", "Johnson", "Williams", "Brown", "Davis", "Wilson" ].sample,
      email: valid_email("patient"),
      phone: valid_phone_number,
      date_of_birth: Date.current - rand(18..80).years,
      gender: [ "male", "female", "other" ].sample,
      emergency_contact_name: "Emergency Contact #{rand(100..999)}",
      emergency_contact_phone: valid_phone_number
    }
  end

  # Generate sample appointment data
  def sample_appointment_attributes
    {
      appointment_date: valid_appointment_date,
      appointment_time: valid_appointment_time,
      status: [ "scheduled", "confirmed", "completed", "cancelled" ].sample,
      notes: "Routine checkup and consultation",
      duration_minutes: [ 15, 30, 45, 60 ].sample
    }
  end

  # Healthcare validation helpers
  def assert_valid_phone_number(phone)
    assert_match /\A\+1\d{10}\z/, phone, "Phone number should be in format +1XXXXXXXXXX"
  end

  def assert_valid_email(email)
    assert_match /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, email, "Email should be valid format"
  end

  def assert_future_appointment_date(date)
    assert date >= Date.current, "Appointment date should be in the future"
  end

  def assert_business_hours_time(time)
    hour = time.hour
    assert hour >= 9 && hour <= 17, "Appointment time should be during business hours (9 AM - 5 PM)"
  end

  # HIPAA compliance helpers
  def assert_no_sensitive_data_in_logs(log_content)
    sensitive_patterns = [
      /\b\d{3}-\d{2}-\d{4}\b/,           # SSN pattern
      /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/, # Credit card pattern
      /medical.record.number/i,           # Medical record references
      /patient.id.*\d+/i                  # Patient ID references
    ]

    sensitive_patterns.each do |pattern|
      refute_match pattern, log_content, "Sensitive data found in logs: #{pattern}"
    end
  end

  # Test data cleanup helpers
  def cleanup_test_appointments
    # This will be implemented when we have the Appointment model
  end

  def cleanup_test_patients
    # This will be implemented when we have the Patient model
  end

  def cleanup_test_doctors
    # This will be implemented when we have the Doctor model
  end

  def cleanup_test_hospitals
    # This will be implemented when we have the Hospital model
  end

  def cleanup_test_clinics
    # This will be implemented when we have the Clinic model
  end
end
