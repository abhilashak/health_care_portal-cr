require_relative "../seed_data"
require "faker"

module Seeds
  class DoctorSeeder
    def self.seed(count = 100)
      puts "👨‍⚕️ Creating Doctors..."

      # Pre-hash password for all records
      password_digest = BCrypt::Password.create("password123")

      # Pre-calculate timestamp for all records
      current_time = Time.current

      # Get facility IDs for assignment
      hospitals = HealthcareFacility.hospitals.pluck(:id)
      clinics = HealthcareFacility.clinics.pluck(:id)

      doctors_data = []

      count.times do |i|
        # Distribute doctors across different facility types
        # Note: All doctors must belong to at least one facility due to DB constraint
        if i < count * 0.4
          # Hospital only
          hospital_id = hospitals.any? ? hospitals.sample : nil
          clinic_id = nil
        elsif i < count * 0.8
          # Clinic only
          hospital_id = nil
          clinic_id = clinics.any? ? clinics.sample : nil
        else
          # Both hospital and clinic
          hospital_id = hospitals.any? ? hospitals.sample : nil
          clinic_id = clinics.any? ? clinics.sample : nil
        end

        doctors_data << {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          specialization: SeedData::SPECIALTIES.sample,
          hospital_id: hospital_id,
          clinic_id: clinic_id,
          email: Faker::Internet.email(domain: "healthcare.com"),
          password_digest: password_digest,
          created_at: current_time,
          updated_at: current_time
        }

        print "." if (i + 1) % 10 == 0
      end

      Doctor.insert_all(doctors_data)
      puts "\n✅ Created #{count} Doctors"
    end
  end
end
