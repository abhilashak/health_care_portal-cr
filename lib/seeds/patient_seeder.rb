require_relative "../seed_data"
require "faker"

module Seeds
  class PatientSeeder
    def self.seed(count = 100)
      puts "👥 Creating Patients..."

      # Pre-hash password for all records
      password_digest = BCrypt::Password.create("password123")

      # Pre-calculate timestamp for all records
      current_time = Time.current

      patients_data = []

      count.times do |i|
        patients_data << {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          date_of_birth: Faker::Date.birthday(min_age: 1, max_age: 90),
          email: Faker::Internet.email,
          password_digest: password_digest,
          created_at: current_time,
          updated_at: current_time
        }

        print "." if (i + 1) % 10 == 0
      end

      Patient.insert_all(patients_data)
      puts "\n✅ Created #{count} Patients"
    end
  end
end
