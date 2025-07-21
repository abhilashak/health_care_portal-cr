module HealthcareTestHelper
  # Test data generators for healthcare entities

  # Generate sample hospital data
  def sample_hospital_attributes
    {
      type: "Hospital",
      name: "General Hospital #{rand(100..999)}",
      address: "#{rand(100..9999)} Medical Center Dr",
      city: "Healthcare City",
      state: "CA",
      zip_code: "9#{rand(1000..9999)}",
      phone: valid_phone_number,
      email: valid_email("hospital"),
      established_date: Date.current - rand(1..50).years,
      website_url: "https://hospital#{rand(100..999)}.com",
      health_care_type: [ "General", "Specialty", "Teaching", "Psychiatric", "Children" ].sample,
      bed_capacity: rand(50..500),
      emergency_services: [ true, false ].sample
    }
  end

  # Generate sample clinic data
  def sample_clinic_attributes
    {
      type: "Clinic",
      name: "#{[ 'Family', 'Pediatric', 'Internal', 'Urgent' ].sample} Clinic #{rand(100..999)}",
      address: "#{rand(100..9999)} Clinic Ave",
      city: "Healthcare City",
      state: "CA",
      zip_code: "9#{rand(1000..9999)}",
      phone: valid_phone_number,
      email: valid_email("clinic"),
      established_date: Date.current - rand(1..30).years,
      website_url: "https://clinic#{rand(100..999)}.com",
      health_care_type: [ "Family Practice", "Urgent Care", "Specialty", "Pediatric", "Internal Medicine" ].sample,
      services_offered: "Primary care, vaccinations, routine checkups, health screenings",
      accepts_walk_ins: [ true, false ].sample
    }
  end

  # Generate sample doctor data matching database schema
  def sample_doctor_attributes
    {
      first_name: [ "Dr. John", "Dr. Sarah", "Dr. Michael", "Dr. Emily" ].sample,
      last_name: [ "Smith", "Johnson", "Williams", "Brown", "Davis" ].sample,
      email: valid_email("doctor"),
      phone: valid_phone_number,
      specialization: [ "Cardiology", "Pediatrics", "Internal Medicine", "Emergency Medicine", "Family Medicine" ].sample,
      license_number: "MD#{rand(100000..999999)}",
      years_of_experience: rand(1..40),
      hospital_id: nil, # Will be set when we have actual facilities
      clinic_id: nil    # Will be set when we have actual facilities
    }
  end

  # Generate sample patient data matching database schema
  def sample_patient_attributes
    {
      first_name: [ "John", "Sarah", "Michael", "Emily", "David", "Lisa" ].sample,
      last_name: [ "Smith", "Johnson", "Williams", "Brown", "Davis", "Wilson" ].sample,
      email: valid_email("patient"),
      phone: valid_phone_number,
      date_of_birth: Date.current - rand(18..80).years,
      gender: [ "male", "female", "other", "prefer_not_to_say" ].sample,
      emergency_contact_name: "Emergency Contact #{rand(100..999)}",
      emergency_contact_phone: valid_phone_number
    }
  end

  # Generate sample appointment data matching database schema
  def sample_appointment_attributes
    {
      doctor_id: nil, # Will be set when we have actual doctors
      patient_id: nil, # Will be set when we have actual patients
      scheduled_at: valid_appointment_datetime,
      status: [ "pending", "confirmed", "in_progress", "completed", "cancelled", "no_show", "rescheduled" ].sample,
      notes: "Routine checkup and consultation for patient health assessment",
      duration_minutes: [ 15, 30, 45, 60, 90 ].sample,
      appointment_type: [ "routine", "follow_up", "emergency", "consultation", "procedure", "surgery", "therapy", "screening", "vaccination", "other" ].sample,
      confirmed_at: nil # Will be set based on status
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

  # Generate valid appointment datetime (combines date and time)
  def valid_appointment_datetime
    appointment_date = valid_appointment_date
    appointment_time = valid_appointment_time

    # Combine date and time
    DateTime.new(
      appointment_date.year,
      appointment_date.month,
      appointment_date.day,
      appointment_time.hour,
      appointment_time.min
    )
  end

  # Healthcare facility validation helpers
  def assert_valid_healthcare_facility_type(facility_type, healthcare_type)
    case facility_type
    when "Hospital"
      valid_hospital_types = [ "General", "Specialty", "Teaching", "Psychiatric", "Rehabilitation", "Children", "Cancer", "Heart", "Other" ]
      assert_includes valid_hospital_types, healthcare_type, "Invalid hospital healthcare type: #{healthcare_type}"
    when "Clinic"
      valid_clinic_types = [ "Family Practice", "Urgent Care", "Specialty", "Pediatric", "Internal Medicine", "Cardiology", "Dermatology", "Orthopedic", "Mental Health", "Dental", "Eye Care", "Other" ]
      assert_includes valid_clinic_types, healthcare_type, "Invalid clinic healthcare type: #{healthcare_type}"
    else
      flunk "Unknown facility type: #{facility_type}"
    end
  end

  def assert_valid_hospital_attributes(attrs)
    assert_equal "Hospital", attrs[:type]
    assert_not_nil attrs[:health_care_type]
    assert_not_nil attrs[:bed_capacity]
    assert_not_nil attrs[:emergency_services]
    assert_valid_healthcare_facility_type("Hospital", attrs[:health_care_type])
    assert attrs[:bed_capacity] >= 0, "Bed capacity should be non-negative"
  end

  def assert_valid_clinic_attributes(attrs)
    assert_equal "Clinic", attrs[:type]
    assert_not_nil attrs[:health_care_type]
    assert_not_nil attrs[:services_offered]
    assert_not_nil attrs[:accepts_walk_ins]
    assert_valid_healthcare_facility_type("Clinic", attrs[:health_care_type])
    assert attrs[:services_offered].length >= 5, "Services offered should have meaningful content"
  end

  # Doctor validation helpers
  def assert_valid_doctor_attributes(attrs)
    assert_not_nil attrs[:first_name]
    assert_not_nil attrs[:last_name]
    assert_not_nil attrs[:email]
    assert_not_nil attrs[:phone]
    assert_not_nil attrs[:specialization]
    assert_not_nil attrs[:license_number]
    assert_not_nil attrs[:years_of_experience]

    assert_valid_email(attrs[:email])
    assert_valid_phone_number(attrs[:phone])
    assert attrs[:years_of_experience] >= 0, "Years of experience should be non-negative"
    assert attrs[:years_of_experience] <= 70, "Years of experience should be reasonable"
    assert attrs[:license_number].length >= 3, "License number should have meaningful length"
    assert attrs[:specialization].length >= 3, "Specialization should have meaningful length"
  end

  # Patient validation helpers
  def assert_valid_patient_attributes(attrs)
    assert_not_nil attrs[:first_name]
    assert_not_nil attrs[:last_name]
    assert_not_nil attrs[:email]
    assert_not_nil attrs[:phone]
    assert_not_nil attrs[:date_of_birth]
    assert_not_nil attrs[:gender]
    assert_not_nil attrs[:emergency_contact_name]
    assert_not_nil attrs[:emergency_contact_phone]

    assert_valid_email(attrs[:email])
    assert_valid_phone_number(attrs[:phone])
    assert_valid_phone_number(attrs[:emergency_contact_phone])

    # Validate gender values
    valid_genders = [ "male", "female", "other", "prefer_not_to_say" ]
    assert_includes valid_genders, attrs[:gender], "Invalid gender value"

    # Validate date of birth
    assert attrs[:date_of_birth] <= Date.current, "Date of birth should not be in the future"
    assert attrs[:date_of_birth] >= Date.new(1900, 1, 1), "Date of birth should be reasonable"

    # Validate emergency contact
    assert attrs[:emergency_contact_name].length >= 2, "Emergency contact name should have meaningful length"
  end

  # Appointment validation helpers
  def assert_valid_appointment_attributes(attrs)
    # Required fields
    assert attrs.key?(:doctor_id), "Appointment should have doctor_id field"
    assert attrs.key?(:patient_id), "Appointment should have patient_id field"
    assert_not_nil attrs[:scheduled_at], "Appointment should have scheduled_at"
    assert_not_nil attrs[:status], "Appointment should have status"
    assert_not_nil attrs[:duration_minutes], "Appointment should have duration_minutes"
    assert_not_nil attrs[:appointment_type], "Appointment should have appointment_type"

    # Validate status
    valid_statuses = [ "pending", "confirmed", "in_progress", "completed", "cancelled", "no_show", "rescheduled" ]
    assert_includes valid_statuses, attrs[:status], "Invalid appointment status"

    # Validate appointment type
    valid_types = [ "routine", "follow_up", "emergency", "consultation", "procedure", "surgery", "therapy", "screening", "vaccination", "other" ]
    assert_includes valid_types, attrs[:appointment_type], "Invalid appointment type"

    # Validate duration
    assert attrs[:duration_minutes] >= 5, "Duration should be at least 5 minutes"
    assert attrs[:duration_minutes] <= 480, "Duration should not exceed 8 hours"

    # Validate scheduled_at is reasonable
    assert attrs[:scheduled_at] >= 1.hour.ago, "Appointment should not be too far in the past"
    assert attrs[:scheduled_at] <= 2.years.from_now, "Appointment should not be too far in the future"
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

  def cleanup_test_healthcare_facilities
    # This will be implemented when we have the HealthcareFacility model
  end
end
