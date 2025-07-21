module Seeds
  class MainSeeder
    def self.seed_all(counts = {})
      counts = default_counts.merge(counts)

      puts "🗑️  Clearing existing data..."
      clear_existing_data

      puts "🌱 Starting to seed data..."

      # Seed in dependency order
      Seeds::HealthcareFacilitySeeder.seed(counts[:facilities])
      Seeds::DoctorSeeder.seed(counts[:doctors])
      Seeds::PatientSeeder.seed(counts[:patients])
      Seeds::AppointmentSeeder.seed(counts[:appointments])

      display_summary
      display_test_credentials
    end

    private

    def self.default_counts
      {
        facilities: 100,
        doctors: 100,
        patients: 100,
        appointments: 100
      }
    end

    def self.clear_existing_data
      Appointment.delete_all
      Doctor.delete_all
      Patient.delete_all
      HealthcareFacility.delete_all
    end

    def self.display_summary
      puts "\n🎉 Seeding completed successfully!"
      puts "\n📊 Summary:"
      puts "   🏥 Healthcare Facilities: #{HealthcareFacility.count}"
      puts "   👨‍⚕️ Doctors: #{Doctor.count}"
      puts "   👥 Patients: #{Patient.count}"
      puts "   📅 Appointments: #{Appointment.count}"
    end

    def self.display_test_credentials
      puts "\n📋 Test Credentials:"
      puts "   🏥 Healthcare Facility: #{HealthcareFacility.first&.email} / password123"
      puts "   👨‍⚕️ Doctor: #{Doctor.first&.email} / password123"
      puts "   👥 Patient: #{Patient.first&.email} / password123"
      puts "\n🔗 Visit /login to test the authentication system!"
    end
  end
end
