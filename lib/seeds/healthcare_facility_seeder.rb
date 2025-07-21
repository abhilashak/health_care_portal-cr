require_relative "../seed_data"
require "faker"

module Seeds
  class HealthcareFacilitySeeder
    def self.seed(count = 100)
      puts "🏥 Creating Healthcare Facilities..."

      # Pre-hash password for all records
      password_digest = BCrypt::Password.create("password123")

      # Pre-calculate timestamp for all records
      current_time = Time.current

      facilities_data = []

      count.times do |i|
        facility_type = i < count / 2 ? "Hospital" : "Clinic"
        facility_name = "#{SeedData::FACILITY_TYPES.sample} #{Faker::Address.city}"

        facilities_data << {
          type: facility_type,
          name: facility_name,
          address: Faker::Address.full_address,
          phone: Faker::PhoneNumber.phone_number,
          email: Faker::Internet.email(domain: "healthcare.com"),
          website: Faker::Internet.url(host: facility_name.downcase.gsub(" ", "").gsub(",", "")),
          registration_number: "REG-#{sprintf('%06d', i + 1)}",
          active: Faker::Boolean.boolean(true_ratio: 0.8),
          contact_person: "Dr. #{Faker::Name.name}",
          contact_person_phone: Faker::PhoneNumber.phone_number,
          contact_person_email: Faker::Internet.email,
          emergency_contact: "Emergency Services",
          emergency_phone: "911",
          operating_hours: default_operating_hours,
          timezone: Faker::Address.time_zone,
          status: SeedData::FACILITY_STATUSES.sample,
          description: Faker::Lorem.paragraph(sentence_count: 3),
          logo_url: Faker::Internet.url(host: "via.placeholder.com", path: "/150x50/0066cc/ffffff?text=#{facility_name.gsub(' ', '+')}"),
          specialties: SeedData::SPECIALTIES.sample(rand(3..8)),
          facility_type: facility_type,
          number_of_doctors: Faker::Number.between(from: 10, to: 100),
          accepts_insurance: Faker::Boolean.boolean,
          accepts_new_patients: Faker::Boolean.boolean(true_ratio: 0.7),
          languages_spoken: [ "English", "Spanish", "French", "German", "Italian" ].sample(rand(2..4)),
          services: SeedData::SERVICES.sample(rand(5..10)),
          password_digest: password_digest,
          created_at: current_time,
          updated_at: current_time
        }

        print "." if (i + 1) % 10 == 0
      end

      HealthcareFacility.insert_all(facilities_data)
      puts "\n✅ Created #{count} Healthcare Facilities"
    end

    private

    def self.default_operating_hours
      {
        monday: "8:00 AM - 6:00 PM",
        tuesday: "8:00 AM - 6:00 PM",
        wednesday: "8:00 AM - 6:00 PM",
        thursday: "8:00 AM - 6:00 PM",
        friday: "8:00 AM - 6:00 PM",
        saturday: "9:00 AM - 4:00 PM",
        sunday: "Closed"
      }
    end
  end
end
