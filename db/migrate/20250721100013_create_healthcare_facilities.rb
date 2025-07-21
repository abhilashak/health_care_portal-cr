class CreateHealthcareFacilities < ActiveRecord::Migration[8.0]
  def change
    create_table :healthcare_facilities do |t|
      # STI type field - required for Single Table Inheritance
      t.string :type, null: false, limit: 50

      # Core facility information - required for all healthcare facilities
      t.string :name, null: false, limit: 255
      t.text :address, null: false

      # Contact information - required for all healthcare institutions
      t.string :phone, null: false, limit: 20
      t.string :email, null: false, limit: 255

      # Location details - required for geographical operations
      t.string :city, null: false, limit: 100
      t.string :state, null: false, limit: 50
      t.string :zip_code, null: false, limit: 10

      # Common operational information
      t.date :established_date, null: false
      t.string :website_url, limit: 500

      # Unified healthcare type field - works for both hospitals and clinics
      t.string :health_care_type, null: false, limit: 100

      # Hospital-specific fields (nullable for clinics)
      t.integer :bed_capacity
      t.boolean :emergency_services

      # Clinic-specific fields (nullable for hospitals)
      t.text :services_offered
      t.boolean :accepts_walk_ins

      # Standard Rails timestamps
      t.timestamps null: false
    end

    # STI and uniqueness indexes
    add_index :healthcare_facilities, :type, name: 'index_healthcare_facilities_type'
    add_index :healthcare_facilities, :name, unique: true, name: 'index_healthcare_facilities_unique_name'
    add_index :healthcare_facilities, :email, unique: true, name: 'index_healthcare_facilities_unique_email'

    # Location and search indexes
    add_index :healthcare_facilities, [ :type, :city, :state ], name: 'index_healthcare_facilities_type_location'
    add_index :healthcare_facilities, :zip_code, name: 'index_healthcare_facilities_zip_code'
    add_index :healthcare_facilities, :established_date, name: 'index_healthcare_facilities_established'

    # Healthcare type indexes (works for both hospitals and clinics)
    add_index :healthcare_facilities, [ :type, :health_care_type ], name: 'index_healthcare_facilities_type_healthcare_type'
    add_index :healthcare_facilities, :health_care_type, name: 'index_healthcare_facilities_healthcare_type'

    # Hospital-specific indexes
    add_index :healthcare_facilities, [ :type, :emergency_services ], where: "type = 'Hospital'", name: 'index_hospitals_emergency'
    add_index :healthcare_facilities, [ :type, :bed_capacity ], where: "type = 'Hospital'", name: 'index_hospitals_bed_capacity'

    # Clinic-specific indexes
    add_index :healthcare_facilities, [ :type, :accepts_walk_ins ], where: "type = 'Clinic'", name: 'index_clinics_walk_ins'

    # Basic data validation constraints
    add_check_constraint :healthcare_facilities, "type IN ('Hospital', 'Clinic')", name: 'check_valid_facility_type'
    add_check_constraint :healthcare_facilities, "LENGTH(name) >= 2", name: 'check_facility_name_length'
    add_check_constraint :healthcare_facilities, "LENGTH(phone) >= 10", name: 'check_facility_phone_length'
    add_check_constraint :healthcare_facilities, "email LIKE '%@%'", name: 'check_facility_email_format'

    # Hospital-specific constraints
    add_check_constraint :healthcare_facilities,
      "(type != 'Hospital') OR (bed_capacity IS NOT NULL AND emergency_services IS NOT NULL)",
      name: 'check_hospital_required_fields'
    add_check_constraint :healthcare_facilities,
      "(type != 'Hospital') OR (bed_capacity >= 0)",
      name: 'check_hospital_bed_capacity_positive'
    add_check_constraint :healthcare_facilities,
      "(type != 'Hospital') OR (health_care_type IN ('General', 'Specialty', 'Teaching', 'Psychiatric', 'Rehabilitation', 'Children', 'Cancer', 'Heart', 'Other'))",
      name: 'check_hospital_valid_healthcare_type'

    # Clinic-specific constraints
    add_check_constraint :healthcare_facilities,
      "(type != 'Clinic') OR (services_offered IS NOT NULL AND accepts_walk_ins IS NOT NULL)",
      name: 'check_clinic_required_fields'
    add_check_constraint :healthcare_facilities,
      "(type != 'Clinic') OR (health_care_type IN ('Family Practice', 'Urgent Care', 'Specialty', 'Pediatric', 'Internal Medicine', 'Cardiology', 'Dermatology', 'Orthopedic', 'Mental Health', 'Dental', 'Eye Care', 'Other'))",
      name: 'check_clinic_valid_healthcare_type'
    add_check_constraint :healthcare_facilities,
      "(type != 'Clinic') OR (LENGTH(services_offered) >= 5)",
      name: 'check_clinic_services_length'
  end
end
