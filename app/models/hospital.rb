class Hospital < HealthcareFacility
  # Hospital-specific associations
  has_many :doctors, foreign_key: "hospital_id", dependent: :nullify
  has_many :appointments, through: :doctors

  # Instance methods
  def doctor_count
    doctors.count
  end

  def available_specializations
    doctors.distinct.pluck(:specialization).compact.sort
  end

  def doctor_count
    doctors.count
  end

  def available_specializations
    doctors.distinct.pluck(:specialization).compact.sort
  end
end
