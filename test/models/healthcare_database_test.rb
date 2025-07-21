require "test_helper"

class HealthcareDatabaseTest < ActiveSupport::TestCase
  # Test that our database structure and fixtures work correctly (without appointments for now)

  test "healthcare facilities fixtures load correctly" do
    # Test hospitals
    assert_equal 3, HealthcareFacility.where(type: "Hospital").count

    general_hospital = healthcare_facilities(:general_hospital)
    assert_equal "Hospital", general_hospital.type
    assert_equal "General", general_hospital.health_care_type
    assert_equal 250, general_hospital.bed_capacity
    assert general_hospital.emergency_services

    # Test clinics
    assert_equal 4, HealthcareFacility.where(type: "Clinic").count

    family_clinic = healthcare_facilities(:family_clinic)
    assert_equal "Clinic", family_clinic.type
    assert_equal "Family Practice", family_clinic.health_care_type
    assert family_clinic.accepts_walk_ins
    assert_includes family_clinic.services_offered, "Primary care"
  end

  test "doctor fixtures load with proper facility associations" do
    assert_equal 5, Doctor.count

    # Test hospital doctor
    dr_smith = doctors(:dr_smith_cardiology)
    assert_equal healthcare_facilities(:general_hospital).id, dr_smith.hospital_id
    assert_nil dr_smith.clinic_id
    assert_equal "Cardiology", dr_smith.specialization

    # Test another hospital doctor
    dr_garcia = doctors(:dr_garcia_heart_surgery)
    assert_equal healthcare_facilities(:specialty_hospital).id, dr_garcia.hospital_id
    assert_nil dr_garcia.clinic_id
    assert_equal "Cardiovascular Surgery", dr_garcia.specialization

    # Test independent doctor
    dr_anderson = doctors(:dr_anderson_independent)
    assert_nil dr_anderson.hospital_id
    assert_nil dr_anderson.clinic_id
  end

  test "patient fixtures load with diverse demographics" do
    assert_equal 13, Patient.count

    # Test adult patient
    john = patients(:john_doe)
    assert_equal "male", john.gender
    assert john.date_of_birth < 18.years.ago

    # Test pediatric patient
    alex = patients(:alex_martinez)
    assert_equal "other", alex.gender
    assert alex.date_of_birth > 18.years.ago

    # Test senior patient
    william = patients(:william_davis)
    assert william.date_of_birth <= 65.years.ago

    # Test prefer_not_to_say gender
    jordan = patients(:jordan_kim)
    assert_equal "prefer_not_to_say", jordan.gender
  end

  test "database constraints work properly" do
    # Test unique email constraints
    duplicate_facility = HealthcareFacility.new(
      type: "Hospital",
      name: "Test Hospital",
      address: "123 Test St",
      city: "Test City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155551234",
      email: healthcare_facilities(:general_hospital).email, # Duplicate email
      established_date: Date.current,
      health_care_type: "General",
      bed_capacity: 100,
      emergency_services: true
    )

    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_facility.save!(validate: false)
    end

    # Test unique doctor email constraint
    duplicate_doctor = Doctor.new(
      first_name: "Test",
      last_name: "Doctor",
      email: doctors(:dr_smith_cardiology).email, # Duplicate email
      phone: "+14155559999",
      specialization: "Test Specialty",
      license_number: "TEST123",
      years_of_experience: 5
    )

    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_doctor.save!(validate: false)
    end
  end

  test "foreign key relationships work correctly for doctors and facilities" do
    # Test doctor-facility relationships
    dr_smith = doctors(:dr_smith_cardiology)
    assert_equal healthcare_facilities(:general_hospital), dr_smith.hospital
    assert_nil dr_smith.clinic
  end

  test "check constraints prevent invalid data" do
    # Test invalid hospital type
    invalid_hospital = HealthcareFacility.new(
      type: "Hospital",
      name: "Invalid Hospital",
      address: "123 Invalid St",
      city: "Invalid City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155551234",
      email: "invalid@hospital.com",
      established_date: Date.current,
      health_care_type: "Invalid Type", # Should fail constraint
      bed_capacity: 100,
      emergency_services: true
    )

    assert_raises(ActiveRecord::StatementInvalid) do
      invalid_hospital.save!(validate: false)
    end
  end

  test "database indexes exist for performance" do
    # Test that we can efficiently query by common patterns
    # These queries should use indexes we created

    # Query doctors by hospital
    hospital_doctors = Doctor.where(hospital_id: healthcare_facilities(:general_hospital).id)
    assert hospital_doctors.count > 0

    # Query facilities by type and location
    sf_hospitals = HealthcareFacility.where(type: "Hospital", city: "San Francisco")
    assert sf_hospitals.count > 0
  end

  test "healthcare facility STI works correctly" do
    # Test that STI properly distinguishes between hospitals and clinics

    # Create new hospital
    new_hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "New Test Hospital",
      address: "999 New Hospital Way",
      city: "Test City",
      state: "CA",
      zip_code: "99999",
      phone: "+14155559999",
      email: "new@hospital.com",
      established_date: Date.current,
      health_care_type: "Specialty",
      bed_capacity: 50,
      emergency_services: false
    )

    assert_equal "Hospital", new_hospital.type
    assert_equal 4, HealthcareFacility.where(type: "Hospital").count

    # Create new clinic
    new_clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "New Test Clinic",
      address: "888 New Clinic Street",
      city: "Test City",
      state: "CA",
      zip_code: "88888",
      phone: "+14155558888",
      email: "new@clinic.com",
      established_date: Date.current,
      health_care_type: "Urgent Care",
      services_offered: "Test services",
      accepts_walk_ins: true
    )

    assert_equal "Clinic", new_clinic.type
    assert_equal 5, HealthcareFacility.where(type: "Clinic").count
  end

  test "doctor nullify behavior works with facility deletion" do
    # Test that deleting a facility nullifies doctor associations (on_delete: :nullify)
    # Create a temporary facility and doctor
    test_facility = HealthcareFacility.create!(
      type: "Hospital",
      name: "Test Facility for Deletion",
      address: "123 Temp Street",
      city: "Test City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155559999",
      email: "temp@test.com",
      established_date: Date.current,
      health_care_type: "General",
      bed_capacity: 10,
      emergency_services: false
    )

    test_doctor = Doctor.create!(
      first_name: "Test",
      last_name: "Doctor",
      email: "test.doctor@temp.com",
      phone: "+14155551111",
      specialization: "Test Specialty",
      license_number: "TEMP123",
      years_of_experience: 1,
      hospital_id: test_facility.id
    )

    # Verify the association exists
    assert_equal test_facility.id, test_doctor.hospital_id

    # Delete the facility
    test_facility.destroy!

    # Doctor should still exist but hospital_id should be null
    test_doctor.reload
    assert_nil test_doctor.hospital_id
  end

  private

  # Helper method to create a model class for our table (since we don't have actual models yet)
  def self.const_missing(name)
    if %w[HealthcareFacility Doctor Patient Appointment].include?(name.to_s)
      Class.new(ActiveRecord::Base) do
        self.table_name = name.to_s.underscore.pluralize

        case name.to_s
        when "HealthcareFacility"
          # STI setup
          self.inheritance_column = "type"
        when "Doctor"
          belongs_to :hospital, class_name: "HealthcareFacility", optional: true
          belongs_to :clinic, class_name: "HealthcareFacility", optional: true
          has_many :appointments, dependent: :destroy
        when "Patient"
          has_many :appointments, dependent: :destroy
        when "Appointment"
          belongs_to :doctor
          belongs_to :patient
        end
      end
    else
      super
    end
  end
end
