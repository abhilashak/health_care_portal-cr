require "test_helper"

class ModelsTest < ActiveSupport::TestCase
  # Completely disable fixtures
  self.use_transactional_tests = true

  # Override to disable fixture loading
  def setup_fixtures
    # Do nothing - no fixtures
  end

  def teardown_fixtures
    # Do nothing - no fixtures
  end

  setup do
    # Clean the database before each test
    [ Appointment, Doctor, Patient, HealthcareFacility ].each(&:delete_all)
  end

  test "can create and validate hospital model" do
    hospital = Hospital.new(
      name: "Test General Hospital",
      address: "123 Test Medical Drive",
      phone: "+14155551234",
      email: "test@hospital.com",
      registration_number: "HOS001",
      active: true,
      status: "active"
    )

    assert hospital.valid?, "Hospital should be valid: #{hospital.errors.full_messages}"
    assert hospital.save!, "Hospital should save successfully"

    # Test STI
    assert_equal "Hospital", hospital.type
    assert hospital.hospital?
    refute hospital.clinic?
  end

  test "can create and validate clinic model" do
    clinic = Clinic.new(
      name: "Test Family Clinic",
      address: "456 Test Clinic Street",
      phone: "+14155556789",
      email: "test@clinic.com",
      registration_number: "CLI001",
      active: true,
      status: "active"
    )

    assert clinic.valid?, "Clinic should be valid: #{clinic.errors.full_messages}"
    assert clinic.save!, "Clinic should save successfully"

    # Test STI
    assert_equal "Clinic", clinic.type
    assert clinic.clinic?
    refute clinic.hospital?
  end

  test "can create and validate doctor model" do
    # First create a hospital for association
    hospital = Hospital.create!(
      name: "Test Hospital for Doctors",
      address: "789 Doctor Hospital Lane",
      phone: "+14155559999",
      email: "doctors@hospital.com",
      registration_number: "HOS002",
      active: true,
      status: "active"
    )

    # Create doctor
    doctor = Doctor.new(
      first_name: "Dr. Test",
      last_name: "Physician",
      specialization: "Internal Medicine",
      hospital_id: hospital.id
    )

    assert doctor.valid?, "Doctor should be valid: #{doctor.errors.full_messages}"
    assert doctor.save!, "Doctor should save successfully"

    # Test associations
    assert_equal hospital.id, doctor.hospital_id
    assert_nil doctor.clinic_id
    assert_equal hospital, doctor.hospital

    # Test instance methods
    assert_equal "Dr. Test Physician", doctor.full_name
    assert_equal "Dr. Physician", doctor.display_name
    assert_equal "Dr. Test Physician, MD", doctor.formal_name
    assert doctor.hospital_affiliated?
    refute doctor.clinic_affiliated?
    refute doctor.independent?
    assert doctor.can_accept_new_patients?
  end

  test "can create and validate patient model" do
    patient = Patient.new(
      first_name: "Test",
      last_name: "Patient",
      email: "test.patient@email.com",
      date_of_birth: 30.years.ago.to_date
    )

    assert patient.valid?, "Patient should be valid: #{patient.errors.full_messages}"
    assert patient.save!, "Patient should save successfully"

    # Test instance methods
    assert_equal "Test Patient", patient.full_name
    assert_equal 30, patient.age
    assert_equal "Adult", patient.age_group
    assert patient.adult?
    refute patient.minor?
    refute patient.senior?
  end

  test "can create and validate appointment model" do
    # Create required associations first
    hospital = Hospital.create!(
      name: "Appointment Test Hospital",
      address: "123 Appointment Drive",
      phone: "+14155551234",
      email: "apt@hospital.com",
      registration_number: "HOS004",
      active: true,
      status: "active"
    )

    doctor = Doctor.create!(
      first_name: "Dr. Appointment",
      last_name: "Doctor",
      specialization: "Family Medicine",
      hospital_id: hospital.id
    )

    patient = Patient.create!(
      first_name: "Appointment",
      last_name: "Patient",
      email: "apt.patient@email.com",
      date_of_birth: 25.years.ago.to_date
    )

    # Create appointment
    appointment = Appointment.new(
      doctor: doctor,
      patient: patient,
      appointment_date: 1.week.from_now.change(hour: 10, min: 0),
      status: "scheduled",
      duration_minutes: 30,
      appointment_type: "routine",
      notes: "Regular checkup"
    )

    assert appointment.valid?, "Appointment should be valid: #{appointment.errors.full_messages}"
    assert appointment.save!, "Appointment should save successfully"

    # Test associations
    assert_equal doctor, appointment.doctor
    assert_equal patient, appointment.patient

    # Test instance methods
    assert_equal "scheduled", appointment.status
    assert_equal "routine", appointment.appointment_type
    assert appointment.can_be_confirmed?
    assert appointment.can_be_cancelled?
    assert appointment.is_upcoming?
    refute appointment.is_past?
    assert_equal "30m", appointment.duration_display

    # Test confirmation
    appointment.confirm!
    assert_equal "confirmed", appointment.status
  end

  test "model associations work correctly" do
    # Create all models
    hospital = Hospital.create!(
      name: "Association Test Hospital",
      address: "123 Association Drive",
      phone: "+14155551234",
      email: "assoc@hospital.com",
      registration_number: "HOS003",
      active: true,
      status: "active"
    )

    doctor = Doctor.create!(
      first_name: "Dr. Association",
      last_name: "Test",
      specialization: "Cardiology",
      hospital_id: hospital.id
    )

    patient = Patient.create!(
      first_name: "Association",
      last_name: "Patient",
      email: "assoc.patient@email.com",
      date_of_birth: 35.years.ago.to_date
    )

    appointment = Appointment.create!(
      doctor: doctor,
      patient: patient,
      appointment_date: 2.weeks.from_now.change(hour: 14, min: 30),
      status: "scheduled",
      duration_minutes: 45,
      appointment_type: "consultation"
    )

    # Test hospital -> doctors association
    assert_includes hospital.doctors, doctor
    assert_equal 1, hospital.doctors.count

    # Test doctor -> appointments association
    assert_includes doctor.appointments, appointment
    assert_equal 1, doctor.appointments.count

    # Test patient -> appointments association
    assert_includes patient.appointments, appointment
    assert_equal 1, patient.appointments.count

    # Test appointment belongs_to associations
    assert_equal doctor, appointment.doctor
    assert_equal patient, appointment.patient
  end

  test "model validations work correctly" do
    # Test invalid hospital
    invalid_hospital = Hospital.new(name: "") # Missing required fields
    refute invalid_hospital.valid?
    assert_includes invalid_hospital.errors[:name], "can't be blank"

    # Test invalid doctor
    invalid_doctor = Doctor.new(first_name: "") # Missing required fields
    refute invalid_doctor.valid?
    assert_includes invalid_doctor.errors[:first_name], "can't be blank"

    # Test invalid patient
    invalid_patient = Patient.new(date_of_birth: 1.day.from_now) # Future birth date
    refute invalid_patient.valid?
    assert_includes invalid_patient.errors[:date_of_birth], "must be in the past"

    # Test invalid appointment
    invalid_appointment = Appointment.new(duration_minutes: 1000) # Too long
    refute invalid_appointment.valid?
    assert_includes invalid_appointment.errors[:duration_minutes], "must be between 5 and 480 minutes (8 hours)"
  end
end
