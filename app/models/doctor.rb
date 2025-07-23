class Doctor < ApplicationRecord
  # Rails 8 Authentication
  has_secure_password

  # Include pg_search for full-text search
  include PgSearch::Model

  # Associations
  belongs_to :hospital, class_name: "HealthcareFacility", optional: true
  belongs_to :clinic, class_name: "HealthcareFacility", optional: true
  has_many :appointments, dependent: :destroy
  has_many :patients, through: :appointments

  # pg_search configuration for full-text search
  pg_search_scope :search_by_name_and_specialization,
                  against: {
                    first_name: "A",
                    last_name: "A",
                    specialization: "B",
                    license_number: "C"
                  },
                  using: {
                    tsearch: {
                      prefix: true,
                      dictionary: "english"
                    }
                  }

  # Validations
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :specialization, presence: true, length: { maximum: 150, minimum: 3 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, length: { minimum: 6 }, if: :password_required?

  # Business logic validations
  validate :cannot_be_associated_with_same_facility_as_both_hospital_and_clinic
  validate :must_be_associated_with_at_least_one_facility, unless: :independent_doctor_allowed?


  # Scopes
  scope :by_specialization, ->(spec) { where(specialization: spec) }
  scope :by_hospital, ->(hospital_id) { where(hospital_id: hospital_id) }
  scope :by_clinic, ->(clinic_id) { where(clinic_id: clinic_id) }
  scope :independent, -> { where(hospital_id: nil, clinic_id: nil) }
  scope :hospital_affiliated, -> { where.not(hospital_id: nil) }
  scope :clinic_affiliated, -> { where.not(clinic_id: nil) }


  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    "Dr. #{last_name}"
  end

  def formal_name
    "#{first_name} #{last_name}, MD"
  end

  def independent?
    hospital_id.nil? && clinic_id.nil?
  end

  def hospital_affiliated?
    hospital_id.present?
  end

  def clinic_affiliated?
    clinic_id.present?
  end

  def dual_affiliated?
    hospital_id.present? && clinic_id.present?
  end

  def primary_facility
    hospital || clinic
  end

  def all_facilities
    [ hospital, clinic ].compact
  end



  def can_accept_new_patients?
    # Business logic: doctors with too many appointments might not accept new patients
    appointments.where("appointment_date > ?", Time.current).count < 50
  end

  def upcoming_appointments_count
    appointments.where("appointment_date > ? AND status != ?", Time.current, "cancelled").count
  end

  def total_patients_count
    patients.distinct.count
  end

  private

  def cannot_be_associated_with_same_facility_as_both_hospital_and_clinic
    return unless hospital_id.present? && clinic_id.present?

    if hospital_id == clinic_id
      errors.add(:clinic_id, "cannot be the same as hospital")
      errors.add(:hospital_id, "cannot be the same as clinic")
    end
  end

  def must_be_associated_with_at_least_one_facility
    if hospital_id.blank? && clinic_id.blank?
      errors.add(:base, "must be associated with at least one healthcare facility")
    end
  end

  def independent_doctor_allowed?
    # Allow independent doctors for certain specializations
    [ "Dermatology", "Psychiatry", "Private Practice" ].include?(specialization)
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
