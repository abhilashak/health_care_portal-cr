# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating sample healthcare facilities..."

# Create sample hospitals
hospitals = [
  {
    name: "General Hospital",
    address: "123 Main Street, Downtown, City, State 12345",
    phone: "15551234567",
    email: "info@generalhospital.com",
    registration_number: "HOSP001",
    active: true,
    status: "active"
  },
  {
    name: "Memorial Medical Center",
    address: "456 Oak Avenue, Westside, City, State 12345",
    phone: "15552345678",
    email: "contact@memorialmedical.com",
    registration_number: "HOSP002",
    active: true,
    status: "active"
  },
  {
    name: "City Regional Hospital",
    address: "789 Pine Street, Eastside, City, State 12345",
    phone: "15553456789",
    email: "info@cityregional.com",
    registration_number: "HOSP003",
    active: true,
    status: "active"
  }
]

hospitals.each do |hospital_data|
  Hospital.create!(hospital_data)
end

# Create sample clinics
clinics = [
  {
    name: "Family Care Clinic",
    address: "321 Elm Street, Northside, City, State 12345",
    phone: "15554567890",
    email: "info@familycareclinic.com",
    registration_number: "CLIN001",
    active: true,
    status: "active"
  },
  {
    name: "Urgent Care Center",
    address: "654 Maple Drive, Southside, City, State 12345",
    phone: "15555678901",
    email: "contact@urgentcare.com",
    registration_number: "CLIN002",
    active: true,
    status: "active"
  },
  {
    name: "Pediatric Specialists",
    address: "987 Cedar Lane, Midtown, City, State 12345",
    phone: "15556789012",
    email: "info@pediatricspecialists.com",
    registration_number: "CLIN003",
    active: true,
    status: "active"
  }
]

clinics.each do |clinic_data|
  Clinic.create!(clinic_data)
end

puts "Created #{Hospital.count} hospitals and #{Clinic.count} clinics"
puts "Sample data has been seeded successfully!"
