require "test_helper"

class DatabaseStructureTest < ActiveSupport::TestCase
  # Test database structure without fixtures to avoid foreign key issues

  test "can create healthcare facilities with STI" do
    # Create hospital
    hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "Test General Hospital",
      address: "123 Test Medical Drive",
      phone: "+14155551234",
      email: "test@hospital.com",
      registration_number: "HOS001",
      active: true,
      status: "active",
      password: "password123"
    )

    assert_equal "Hospital", hospital.type
    assert hospital.active
    assert_equal "active", hospital.status

    # Create clinic
    clinic = HealthcareFacility.create!(
      type: "Clinic",
      name: "Test Family Clinic",
      address: "456 Test Clinic Street",
      phone: "+14155556789",
      email: "test@clinic.com",
      registration_number: "CLI001",
      active: true,
      status: "active",
      password: "password123"
    )

    assert_equal "Clinic", clinic.type
    assert clinic.active
    assert_equal "active", clinic.status
  end

  test "can create doctors with facility associations" do
    # First create a hospital
    hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "Unique Test Hospital for Doctors #{Time.current.to_f}",
      address: "789 Doctor Hospital Lane",
      phone: "+14155559999",
      email: "unique.doctors.#{Time.current.to_f}@hospital.com",
      registration_number: "HOS#{Time.current.to_f}",
      active: true,
      status: "active",
      password: "password123"
    )

    # Create doctor associated with hospital
    doctor = Doctor.create!(
      first_name: "Dr. Test",
      last_name: "Physician",
      email: "unique.test.doctor.#{Time.current.to_f}@hospital.com",
      specialization: "Internal Medicine",
      hospital_id: hospital.id,
      password: "password123"
    )

    assert_equal hospital.id, doctor.hospital_id
    assert_nil doctor.clinic_id
    assert_equal "Internal Medicine", doctor.specialization

    # Test association
    assert_equal hospital, doctor.hospital
  end

  test "can create patients with proper constraints" do
    patient = Patient.create!(
      first_name: "Test",
      last_name: "Patient",
      email: "test.patient@email.com",
      date_of_birth: 30.years.ago.to_date,
      password: "password123"
    )

    assert_equal "Test", patient.first_name
    assert_equal "female", patient.gender
    assert patient.date_of_birth < 18.years.ago
  end

  test "database constraints prevent invalid data" do
    # Create a facility with unique email
    HealthcareFacility.create!(
      type: "Hospital",
      name: "Unique Test Hospital",
      address: "123 Unique Drive",
      phone: "+14155551234",
      email: "unique@test.com",
      registration_number: "HOS001",
      active: true,
      status: "active",
      password: "password123"
    )

    # Try to create another with same email (bypass validations to test DB constraint)
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_facility = HealthcareFacility.new(
        type: "Clinic",
        name: "Different Clinic",
        address: "456 Different Street",
        phone: "+14155556789",
        email: "unique@test.com", # Duplicate email
        registration_number: "CLI001",
        active: true,
        status: "active",
        password: "password123"
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
      phone: "+14155551234",
      email: "fk@test.com",
      registration_number: "HOS002",
      active: true,
      status: "active",
      password: "password123"
    )

    # Create doctor
    doctor = Doctor.create!(
      first_name: "FK",
      last_name: "Doctor",
      email: "fk.doctor@test.com",
      specialization: "Test Specialty",
      hospital_id: hospital.id,
      password: "password123"
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
    # This test is no longer applicable since we removed health_care_type
    # Instead, test that we can create valid facilities
    hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "Valid Hospital",
      address: "123 Valid Drive",
      phone: "+14155551234",
      email: "valid@test.com",
      registration_number: "HOS003",
      active: true,
      status: "active",
      password: "password123"
    )

    assert hospital.valid?
    assert hospital.save!
  end

  test "database schema has required indexes" do
    # This test verifies that our migrations created the proper indexes
    # We can check this through the Rails schema

    # Check healthcare_facilities indexes
    indexes = ActiveRecord::Base.connection.indexes("healthcare_facilities")
    index_names = indexes.map(&:name)

    # Check for some expected indexes (adjust based on actual schema)
    assert_includes index_names, "index_healthcare_facilities_on_email"
    assert_includes index_names, "index_healthcare_facilities_on_searchable"

    # Check doctors indexes
    doctor_indexes = ActiveRecord::Base.connection.indexes("doctors")
    doctor_index_names = doctor_indexes.map(&:name)

    # Check for some expected indexes (adjust based on actual schema)
    assert_includes doctor_index_names, "index_doctors_on_email"
    assert_includes doctor_index_names, "index_doctors_on_searchable"
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
