require_relative "../seed_data"
require "faker"

module Seeds
  class AppointmentSeeder
    def self.seed(count = 100)
      puts "📅 Creating Appointments..."

      # Pre-calculate timestamp for all records
      current_time = Time.current

      # Get doctor and patient IDs for assignment
      doctor_ids = Doctor.pluck(:id)
      patient_ids = Patient.pluck(:id)

      appointments_data = []

      count.times do |i|
        # Generate appointment date (some in past, some in future)
        if i < count * 0.3
          # Past appointments
          appointment_date = rand(1..365).days.ago
          status = [ "completed", "cancelled", "no_show" ].sample
        elsif i < count * 0.8
          # Future appointments
          appointment_date = rand(1..90).days.from_now
          status = [ "scheduled", "confirmed" ].sample
        else
          # Today's appointments
          appointment_date = Time.current + rand(1..23).hours
          status = [ "scheduled", "confirmed" ].sample
        end

        appointments_data << {
          doctor_id: doctor_ids.sample,
          patient_id: patient_ids.sample,
          appointment_date: appointment_date,
          status: status,
          notes: Faker::Lorem.sentence(word_count: 10),
          duration_minutes: SeedData::APPOINTMENT_DURATIONS.sample,
          appointment_type: SeedData::APPOINTMENT_TYPES.sample,
          created_at: current_time,
          updated_at: current_time
        }

        print "." if (i + 1) % 10 == 0
      end

      Appointment.insert_all(appointments_data)
      puts "\n✅ Created #{count} Appointments"
    end
  end
end
