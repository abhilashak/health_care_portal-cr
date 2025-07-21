class CreateDoctors < ActiveRecord::Migration[8.0]
  def change
    create_table :doctors do |t|
      # Personal information - required fields
      t.string :first_name, null: false, limit: 100
      t.string :last_name, null: false, limit: 100

      # Contact information - required for communication
      t.string :email, null: false, limit: 255
      t.string :phone, null: false, limit: 20

      # Professional information - required for healthcare operations
      t.string :specialization, null: false, limit: 150
      t.string :license_number, null: false, limit: 50
      t.integer :years_of_experience, null: false, default: 0

      # Healthcare facility associations - nullable (doctors can work independently)
      # Both reference healthcare_facilities table due to STI
      t.bigint :hospital_id, null: true
      t.bigint :clinic_id, null: true

      # Standard Rails timestamps
      t.timestamps null: false
    end

    # Foreign key constraints to healthcare_facilities (STI table)
    add_foreign_key :doctors, :healthcare_facilities, column: :hospital_id, on_delete: :nullify
    add_foreign_key :doctors, :healthcare_facilities, column: :clinic_id, on_delete: :nullify

    # Indexes for performance and uniqueness
    add_index :doctors, :email, unique: true, name: 'idx_doctors_unique_email'
    add_index :doctors, :license_number, unique: true, name: 'idx_doctors_unique_license'
    add_index :doctors, :hospital_id, name: 'idx_doctors_hospital_id'
    add_index :doctors, :clinic_id, name: 'idx_doctors_clinic_id'
    add_index :doctors, :specialization, name: 'idx_doctors_specialization'
    add_index :doctors, [ :last_name, :first_name ], name: 'idx_doctors_name'
    add_index :doctors, :years_of_experience, name: 'idx_doctors_experience'

    # Composite index for facility searches
    add_index :doctors, [ :hospital_id, :specialization ], name: 'idx_doctors_hospital_specialization'
    add_index :doctors, [ :clinic_id, :specialization ], name: 'idx_doctors_clinic_specialization'

    # Check constraints for data validation
    add_check_constraint :doctors, "LENGTH(first_name) >= 2", name: 'check_doctors_first_name_length'
    add_check_constraint :doctors, "LENGTH(last_name) >= 2", name: 'check_doctors_last_name_length'
    add_check_constraint :doctors, "email LIKE '%@%'", name: 'check_doctors_email_format'
    add_check_constraint :doctors, "LENGTH(phone) >= 10", name: 'check_doctors_phone_length'
    add_check_constraint :doctors, "LENGTH(license_number) >= 3", name: 'check_doctors_license_length'
    add_check_constraint :doctors, "years_of_experience >= 0 AND years_of_experience <= 70", name: 'check_doctors_experience_range'
    add_check_constraint :doctors, "LENGTH(specialization) >= 3", name: 'check_doctors_specialization_length'

    # Business logic constraints
    add_check_constraint :doctors, "(hospital_id IS NULL) OR (clinic_id IS NULL) OR (hospital_id != clinic_id)", name: 'check_doctors_different_facilities'
  end
end
