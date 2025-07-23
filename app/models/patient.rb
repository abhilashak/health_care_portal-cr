class Patient < ApplicationRecord
  # Rails 8 Authentication
  has_secure_password

  # Include pg_search for full-text search
  include PgSearch::Model

  # Associations
  has_many :appointments, dependent: :destroy
  has_many :doctors, through: :appointments

  # pg_search configuration for full-text search
  pg_search_scope :search_by_name_and_email,
                  against: {
                    first_name: "A",
                    last_name: "A",
                    email: "B",
                    phone: "C"
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
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :date_of_birth, presence: true
  validates :password, length: { minimum: 6 }, if: :password_required?

  # Date validations
  validate :date_of_birth_must_be_in_past
  validate :date_of_birth_must_be_reasonable



  # Scopes
  scope :adults, -> { where("date_of_birth <= ?", 18.years.ago) }
  scope :minors, -> { where("date_of_birth > ?", 18.years.ago) }
  scope :seniors, -> { where("date_of_birth <= ?", 65.years.ago) }
  scope :pediatric, -> { where("date_of_birth > ?", 18.years.ago) }
  scope :born_in_year, ->(year) { where("EXTRACT(year FROM date_of_birth) = ?", year) }
  scope :by_age_range, ->(min_age, max_age) {
    where(
      "date_of_birth <= ? AND date_of_birth >= ?",
      min_age.years.ago,
      max_age.years.ago
    )
  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    full_name
  end

  def age
    return nil unless date_of_birth

    today = Date.current
    age = today.year - date_of_birth.year
    age -= 1 if today < date_of_birth + age.years
    age
  end

  def age_group
    current_age = age
    return "Unknown" unless current_age

    case current_age
    when 0..2
      "Infant"
    when 3..12
      "Child"
    when 13..17
      "Adolescent"
    when 18..64
      "Adult"
    else
      "Senior"
    end
  end

  def minor?
    age && age < 18
  end

  def adult?
    age && age >= 18
  end

  def senior?
    age && age >= 65
  end

  def pediatric_patient?
    minor?
  end

  def upcoming_appointments
    appointments.where("appointment_date > ? AND status != ?", Time.current, "cancelled")
               .order(:appointment_date)
  end

  def past_appointments
    appointments.where("appointment_date <= ?", Time.current)
               .order(appointment_date: :desc)
  end

  def total_appointments_count
    appointments.count
  end

  def has_upcoming_appointments?
    upcoming_appointments.exists?
  end

  def primary_doctor
    # Find the doctor with whom the patient has the most appointments
    doctors.joins(:appointments)
           .group("doctors.id")
           .order("COUNT(appointments.id) DESC")
           .first
  end

  def contact_info
    email
  end

  private

  def date_of_birth_must_be_in_past
    return unless date_of_birth

    if date_of_birth >= Date.current
      errors.add(:date_of_birth, "must be in the past")
    end
  end

  def date_of_birth_must_be_reasonable
    return unless date_of_birth

    if date_of_birth < 150.years.ago
      errors.add(:date_of_birth, "cannot be more than 150 years ago")
    end

    if date_of_birth > Date.current
      errors.add(:date_of_birth, "cannot be in the future")
    end
  end

  def password_required?
    new_record? || password.present?
  end
end
