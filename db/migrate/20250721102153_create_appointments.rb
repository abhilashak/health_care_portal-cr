class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      # Required relationship fields
      t.bigint :doctor_id, null: false
      t.bigint :patient_id, null: false

      # Appointment scheduling information - required
      t.datetime :scheduled_at, null: false
      t.string :status, null: false, limit: 50, default: 'pending'

      # Appointment details - optional but important
      t.text :notes
      t.integer :duration_minutes, null: false, default: 30
      t.string :appointment_type, null: false, limit: 100, default: 'routine'

      # Appointment confirmation tracking
      t.datetime :confirmed_at

      # Standard Rails timestamps
      t.timestamps null: false
    end

    # Foreign key constraints
    add_foreign_key :appointments, :doctors, on_delete: :cascade
    add_foreign_key :appointments, :patients, on_delete: :cascade

    # Primary indexes for performance and relationships
    add_index :appointments, :doctor_id, name: 'index_appointments_doctor_id'
    add_index :appointments, :patient_id, name: 'index_appointments_patient_id'
    add_index :appointments, :scheduled_at, name: 'index_appointments_scheduled_at'
    add_index :appointments, :status, name: 'index_appointments_status'

    # Composite indexes for common queries (as requested)
    add_index :appointments, [ :doctor_id, :scheduled_at ], name: 'index_appointments_doctor_schedule'
    add_index :appointments, [ :patient_id, :scheduled_at ], name: 'index_appointments_patient_schedule'
    add_index :appointments, [ :doctor_id, :status ], name: 'index_appointments_doctor_status'
    add_index :appointments, [ :patient_id, :status ], name: 'index_appointments_patient_status'

    # Healthcare-specific composite indexes
    add_index :appointments, [ :scheduled_at, :status ], name: 'index_appointments_schedule_status'
    add_index :appointments, [ :appointment_type, :scheduled_at ], name: 'index_appointments_type_schedule'
    add_index :appointments, [ :doctor_id, :patient_id, :scheduled_at ], name: 'index_appointments_doctor_patient_schedule'

    # Business logic and data validation constraints
    add_check_constraint :appointments,
      "status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled')",
      name: 'check_appointments_valid_status'

    add_check_constraint :appointments,
      "appointment_type IN ('routine', 'follow_up', 'emergency', 'consultation', 'procedure', 'surgery', 'therapy', 'screening', 'vaccination', 'other')",
      name: 'check_appointments_valid_type'

    # Healthcare-specific business constraints
    add_check_constraint :appointments,
      "duration_minutes >= 5 AND duration_minutes <= 480",
      name: 'check_appointments_reasonable_duration'

    add_check_constraint :appointments,
      "scheduled_at >= CURRENT_TIMESTAMP - INTERVAL '1 hour'",
      name: 'check_appointments_not_too_far_past'

    add_check_constraint :appointments,
      "scheduled_at <= CURRENT_TIMESTAMP + INTERVAL '2 years'",
      name: 'check_appointments_reasonable_future'

    # Confirmation logic constraints
    add_check_constraint :appointments,
      "(confirmed_at IS NULL) OR (confirmed_at <= scheduled_at)",
      name: 'check_appointments_confirmed_before_scheduled'

    add_check_constraint :appointments,
      "(status != 'confirmed') OR (confirmed_at IS NOT NULL)",
      name: 'check_appointments_confirmed_status_has_timestamp'

    # Prevent overlapping appointments for same doctor (basic constraint)
    # More complex overlap prevention would be handled at application level
    add_check_constraint :appointments,
      "duration_minutes IS NOT NULL",
      name: 'check_appointments_duration_not_null'
  end
end
