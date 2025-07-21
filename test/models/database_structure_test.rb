require "test_helper"

class DatabaseStructureTest < ActiveSupport::TestCase
  # Test database structure without fixtures to avoid foreign key issues

  test "can create healthcare facilities with STI" do
    # Create hospital
    hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "Test General Hospital",
      address: "123 Test Medical Drive",
      city: "Test City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155551234",
      email: "test@hospital.com",
      established_date: Date.current,
      health_care_type: "General",
      bed_capacity: 100,
      emergency_services: true
    )

    assert_equal "Hospital", hospital.type
    assert_equal "General", hospital.health_care_type
    assert hospital.emergency_services
    assert_equal 100, hospital.bed_capacity

    # Create clinic
    clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Test Family Clinic",
      address: "456 Test Clinic Street",
      city: "Test City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155556789",
      email: "test@clinic.com",
      established_date: Date.current,
      health_care_type: "Family Practice",
      services_offered: "Primary care, vaccinations",
      accepts_walk_ins: true
    )

    assert_equal "Clinic", clinic.type
    assert_equal "Family Practice", clinic.health_care_type
    assert clinic.accepts_walk_ins
    assert_includes clinic.services_offered, "Primary care"
  end

  test "can create doctors with facility associations" do
    # First create a hospital
    hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "Unique Test Hospital for Doctors #{Time.current.to_f}",
      address: "789 Doctor Hospital Lane",
      city: "Test City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155559999",
      email: "unique.doctors.#{Time.current.to_f}@hospital.com",
      established_date: Date.current,
      health_care_type: "General",
      bed_capacity: 50,
      emergency_services: true
    )

    # Create doctor associated with hospital
    doctor = Doctor.create!(
      first_name: "Dr. Test",
      last_name: "Physician",
      email: "unique.test.doctor.#{Time.current.to_f}@hospital.com",
      phone: "+14155551111",
      specialization: "Internal Medicine",
      license_number: "UNIQUE#{Time.current.to_f}",
      years_of_experience: 10,
      hospital_id: hospital.id
    )

    assert_equal hospital.id, doctor.hospital_id
    assert_nil doctor.clinic_id
    assert_equal "Internal Medicine", doctor.specialization
    assert_equal 10, doctor.years_of_experience

    # Test association
    assert_equal hospital, doctor.hospital
  end

  test "can create patients with proper constraints" do
    patient = Patient.create!(
      first_name: "Test",
      last_name: "Patient",
      email: "test.patient@email.com",
      phone: "+14155552222",
      date_of_birth: 30.years.ago.to_date,
      gender: "female",
      emergency_contact_name: "Emergency Contact",
      emergency_contact_phone: "+14155553333"
    )

    assert_equal "Test", patient.first_name
    assert_equal "female", patient.gender
    assert patient.date_of_birth < 18.years.ago
  end

  test "database constraints prevent invalid data" do
    # Test unique email constraint for facilities
    HealthcareFacility.create!(
      type: "Hospital",
      name: "First Hospital",
      address: "123 Test Drive",
      city: "Test City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155551234",
      email: "unique@test.com",
      established_date: Date.current,
      health_care_type: "General",
      bed_capacity: 50,
      emergency_services: true
    )

    # Try to create another with same email (bypass validations to test DB constraint)
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_facility = HealthcareFacility.new(
        type: "Clinic",
        name: "Different Clinic",
        address: "456 Different Street",
        city: "Test City",
        state: "CA",
        zip_code: "12345",
        phone: "+14155556789",
        email: "unique@test.com", # Duplicate email
        established_date: Date.current,
        health_care_type: "Family Practice",
        accepts_walk_ins: true,
        services_offered: "Primary care services"
      )
      duplicate_facility.save!(validate: false)
    end
  end

  test "foreign key constraints work for doctor-facility relationships" do
    # Create hospital
    hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "FK Test Hospital",
      address: "123 FK Test Drive",
      city: "Test City",
      state: "CA",
      zip_code: "12345",
      phone: "+14155551234",
      email: "fk@test.com",
      established_date: Date.current,
      health_care_type: "General",
      bed_capacity: 50,
      emergency_services: true
    )

    # Create doctor
    doctor = Doctor.create!(
      first_name: "FK",
      last_name: "Doctor",
      email: "fk.doctor@test.com",
      phone: "+14155551111",
      specialization: "Test Specialty",
      license_number: "FK123",
      years_of_experience: 5,
      hospital_id: hospital.id
    )

    # Verify association exists
    assert_equal hospital.id, doctor.hospital_id

    # Delete hospital - should nullify doctor's hospital_id (on_delete: :nullify)
    hospital.destroy!

    # Doctor should still exist but hospital_id should be null
    doctor.reload
    assert_nil doctor.hospital_id
  end

  test "check constraints prevent invalid health_care_type" do
    # Try to create hospital with invalid health_care_type (bypass validations to test DB constraint)
    assert_raises(ActiveRecord::StatementInvalid) do
      invalid_facility = HealthcareFacility.new(
        type: "Hospital",
        name: "Invalid Type Hospital",
        address: "123 Invalid Drive",
        city: "Test City",
        state: "CA",
        zip_code: "12345",
        phone: "+14155551234",
        email: "invalid@test.com",
        established_date: Date.current,
        health_care_type: "Invalid Type", # Should fail constraint
        bed_capacity: 50,
        emergency_services: true
      )
      invalid_facility.save!(validate: false)
    end
  end

  test "database schema has required indexes" do
    # This test verifies that our migrations created the proper indexes
    # We can check this through the Rails schema

    # Check healthcare_facilities indexes
    indexes = ActiveRecord::Base.connection.indexes("healthcare_facilities")
    index_names = indexes.map(&:name)

    assert_includes index_names, "index_healthcare_facilities_unique_name"
    assert_includes index_names, "index_healthcare_facilities_unique_email"

    # Check doctors indexes
    doctor_indexes = ActiveRecord::Base.connection.indexes("doctors")
    doctor_index_names = doctor_indexes.map(&:name)

    # Check for actual index names from our migration
    assert_includes doctor_index_names, "idx_doctors_unique_email"
    assert_includes doctor_index_names, "idx_doctors_hospital_id"
    assert_includes doctor_index_names, "idx_doctors_clinic_id"
  end

  private

  # Helper method to create model classes dynamically
  def self.const_missing(name)
    if %w[HealthcareFacility Doctor Patient].include?(name.to_s)
      Class.new(ActiveRecord::Base) do
        self.table_name = name.to_s.underscore.pluralize

        case name.to_s
        when "HealthcareFacility"
          self.inheritance_column = "type"
        when "Doctor"
          belongs_to :hospital, class_name: "HealthcareFacility", optional: true
          belongs_to :clinic, class_name: "HealthcareFacility", optional: true
        when "Patient"
          # Patient model setup
        end
      end
    else
      super
    end
  end
end
