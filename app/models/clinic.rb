class Clinic < HealthcareFacility
  # Clinic-specific associations
  has_many :doctors, foreign_key: "clinic_id", dependent: :nullify
  has_many :appointments, through: :doctors

  # Instance methods
  def doctor_count
    doctors.count
  end

  def available_specializations
    doctors.distinct.pluck(:specialization).compact.sort
  end
end
