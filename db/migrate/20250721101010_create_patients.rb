class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      # Personal information - required fields
      t.string :first_name, null: false, limit: 100
      t.string :last_name, null: false, limit: 100

      # Contact information - required for patient records
      t.string :email, null: false, limit: 255
      t.string :phone, null: false, limit: 20

      # Healthcare information - required for medical records
      t.date :date_of_birth, null: false
      t.string :gender, null: false, limit: 20

      # Emergency contact information - required for safety
      t.string :emergency_contact_name, null: false, limit: 150
      t.string :emergency_contact_phone, null: false, limit: 20

      # Standard Rails timestamps
      t.timestamps null: false
    end

    # Indexes for performance and uniqueness
    add_index :patients, :email, unique: true, name: 'idx_patients_unique_email'
    add_index :patients, [ :last_name, :first_name ], name: 'idx_patients_name'
    add_index :patients, :date_of_birth, name: 'idx_patients_birth_date'
    add_index :patients, :phone, name: 'idx_patients_phone'
    add_index :patients, :gender, name: 'idx_patients_gender'

    # Composite indexes for common searches
    add_index :patients, [ :last_name, :first_name, :date_of_birth ], name: 'idx_patients_identification'
    add_index :patients, [ :gender, :date_of_birth ], name: 'idx_patients_demographics'

    # Check constraints for data validation
    add_check_constraint :patients, "LENGTH(first_name) >= 2", name: 'check_patients_first_name_length'
    add_check_constraint :patients, "LENGTH(last_name) >= 2", name: 'check_patients_last_name_length'
    add_check_constraint :patients, "email LIKE '%@%'", name: 'check_patients_email_format'
    add_check_constraint :patients, "LENGTH(phone) >= 10", name: 'check_patients_phone_length'
    add_check_constraint :patients, "LENGTH(emergency_contact_phone) >= 10", name: 'check_patients_emergency_phone_length'
    add_check_constraint :patients, "LENGTH(emergency_contact_name) >= 2", name: 'check_patients_emergency_name_length'

    # Healthcare-specific constraints
    add_check_constraint :patients, "gender IN ('male', 'female', 'other', 'prefer_not_to_say')", name: 'check_patients_valid_gender'
    add_check_constraint :patients, "date_of_birth <= CURRENT_DATE", name: 'check_patients_birth_date_past'
    add_check_constraint :patients, "date_of_birth >= '1900-01-01'", name: 'check_patients_birth_date_reasonable'

    # Age calculation constraint (patients should be reasonable age for healthcare)
    add_check_constraint :patients, "date_of_birth >= CURRENT_DATE - INTERVAL '150 years'", name: 'check_patients_maximum_age'
  end
end
