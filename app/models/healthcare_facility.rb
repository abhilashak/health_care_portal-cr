class HealthcareFacility < ApplicationRecord
  # Rails 8 Authentication
  has_secure_password

  # Single Table Inheritance (STI) - base class for Hospital and Clinic

  # Associations
  has_many :hospital_doctors, -> { where.not(hospital_id: nil) },
           class_name: "Doctor", foreign_key: "hospital_id", dependent: :nullify
  has_many :clinic_doctors, -> { where.not(clinic_id: nil) },
           class_name: "Doctor", foreign_key: "clinic_id", dependent: :nullify

  # Validations - Common to all healthcare facilities
  validates :type, presence: true, inclusion: { in: %w[Hospital Clinic] }
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :address, presence: true
  validates :phone, presence: true, length: { maximum: 20 },
            format: { with: /\A\+?[1-9]\d{1,14}\z/, message: "must be a valid phone number" }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :registration_number, presence: true, uniqueness: true
  validates :active, inclusion: { in: [ true, false ] }
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended] }
  validates :website, length: { maximum: 500 }, allow_blank: true,
            format: { with: /\Ahttps?:\/\/.+\z/, message: "must be a valid URL" }, if: :website?
  validates :password, length: { minimum: 6 }, if: :password_required?

  # Scopes
  scope :hospitals, -> { where(type: "Hospital") }
  scope :clinics, -> { where(type: "Clinic") }
  scope :active, -> { where(active: true) }
  scope :by_status, ->(status) { where(status: status) }
  scope :accepts_insurance, -> { where(accepts_insurance: true) }
  scope :accepts_new_patients, -> { where(accepts_new_patients: true) }

  # Public methods for type checking
  def hospital?
    type == "Hospital"
  end

  def clinic?
    type == "Clinic"
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
