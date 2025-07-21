# Static data for seeding the healthcare portal database
# Only keeping data that Faker cannot generate

module SeedData
  # Medical Specialties (Faker doesn't have comprehensive medical specialties)
  SPECIALTIES = [
    "Cardiology", "Neurology", "Orthopedics", "Pediatrics", "Oncology", "Dermatology",
    "Psychiatry", "Emergency Medicine", "Internal Medicine", "Surgery", "Radiology",
    "Anesthesiology", "Obstetrics", "Gynecology", "Ophthalmology", "ENT", "Urology",
    "Gastroenterology", "Endocrinology", "Rheumatology"
  ]

  # Healthcare Services (Faker doesn't have healthcare-specific services)
  SERVICES = [
    "Emergency Care", "Surgery", "Diagnostic Imaging", "Laboratory Services", "Pharmacy",
    "Physical Therapy", "Mental Health Services", "Maternity Care", "Pediatric Care",
    "Geriatric Care", "Rehabilitation", "Preventive Care", "Chronic Disease Management"
  ]

  # Healthcare Facility Types (for naming)
  FACILITY_TYPES = [
    "General Hospital", "Medical Center", "Community Clinic", "Specialty Hospital",
    "Urgent Care Center", "Family Medical Center", "Regional Hospital", "Medical Plaza",
    "Health Center", "Wellness Clinic", "Emergency Hospital", "Primary Care Clinic",
    "Surgical Center", "Pediatric Hospital", "Women's Health Center", "Cardiac Center",
    "Orthopedic Hospital", "Neurology Center", "Oncology Hospital", "Rehabilitation Center"
  ]

  # Appointment Types (Faker doesn't have medical appointment types)
  APPOINTMENT_TYPES = [
    "Check-up", "Consultation", "Follow-up", "Emergency", "Surgery", "Physical Therapy",
    "Mental Health", "Laboratory Test", "Imaging", "Vaccination", "Dental", "Eye Exam",
    "Cardiology", "Neurology", "Orthopedics", "Pediatrics", "Oncology", "Dermatology"
  ]

  # Appointment Durations
  APPOINTMENT_DURATIONS = [ 15, 30, 45, 60, 90 ]

  # Appointment Statuses
  APPOINTMENT_STATUSES = [ "scheduled", "confirmed", "completed", "cancelled", "no_show" ]

  # Facility Statuses
  FACILITY_STATUSES = [ "active", "active", "active", "inactive", "suspended" ]
end
