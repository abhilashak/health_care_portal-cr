class Appointment < ApplicationRecord
  # Associations
  belongs_to :doctor
  belongs_to :patient

  # Constants
  VALID_STATUSES = %w[scheduled confirmed completed cancelled no_show].freeze
  VALID_APPOINTMENT_TYPES = %w[routine follow_up emergency consultation procedure surgery therapy screening vaccination other].freeze

  # Validations
  validates :doctor_id, presence: true
  validates :patient_id, presence: true
  validates :appointment_date, presence: true
  validates :status, presence: true, inclusion: {
    in: VALID_STATUSES,
    message: "must be one of: #{VALID_STATUSES.join(', ')}"
  }
  validates :duration_minutes, presence: true, numericality: {
    greater_than_or_equal_to: 5,
    less_than_or_equal_to: 480,
    only_integer: true,
    message: "must be between 5 and 480 minutes (8 hours)"
  }
  validates :appointment_type, presence: true, inclusion: {
    in: VALID_APPOINTMENT_TYPES,
    message: "must be one of: #{VALID_APPOINTMENT_TYPES.join(', ')}"
  }

  # Business logic validations
  validate :appointment_date_must_be_in_reasonable_future
  validate :appointment_date_cannot_be_too_far_in_past
  validate :no_double_booking_for_doctor
  validate :reasonable_appointment_hours

  # Callbacks
  before_validation :set_default_values
  after_update :handle_status_changes

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_type, ->(type) { where(appointment_type: type) }
  scope :by_doctor, ->(doctor_id) { where(doctor_id: doctor_id) }
  scope :by_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :upcoming, -> { where("appointment_date > ?", Time.current) }
  scope :past, -> { where("appointment_date <= ?", Time.current) }
  scope :today, -> { where(appointment_date: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(appointment_date: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :scheduled, -> { where(status: "scheduled") }
  scope :completed, -> { where(status: "completed") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :emergency, -> { where(appointment_type: "emergency") }
  scope :routine, -> { where(appointment_type: "routine") }
  scope :for_date, ->(date) { where(appointment_date: date.beginning_of_day..date.end_of_day) }
  scope :between_dates, ->(start_date, end_date) { where(appointment_date: start_date..end_date) }
  scope :long_appointments, -> { where("duration_minutes >= ?", 60) }
  scope :short_appointments, -> { where("duration_minutes <= ?", 30) }

  # Class methods
  # TODO: to be modified later
  def self.available_slots_for_doctor(doctor, date, duration = 30)
    # Find available time slots for a doctor on a given date
    business_hours = (9..17) # 9 AM to 5 PM
    existing_appointments = where(doctor: doctor, appointment_date: date.beginning_of_day..date.end_of_day)
                          .where.not(status: [ "cancelled", "no_show" ])

    available_slots = []
    business_hours.each do |hour|
      slot_time = date.beginning_of_day + hour.hours
      slot_end = slot_time + duration.minutes

      # Check if this slot conflicts with existing appointments
      conflicts = existing_appointments.any? do |apt|
        apt_start = apt.appointment_date
        apt_end = apt.appointment_date + apt.duration_minutes.minutes

        # Check for overlap
        slot_time < apt_end && slot_end > apt_start
      end

      available_slots << slot_time unless conflicts
    end

    available_slots
  end

  # Instance methods
  def scheduled_date
    appointment_date&.to_date
  end

  def scheduled_time
    appointment_date&.strftime("%I:%M %p")
  end

  def scheduled_datetime_display
    appointment_date&.strftime("%B %d, %Y at %I:%M %p")
  end

  def end_time
    return nil unless appointment_date && duration_minutes

    appointment_date + duration_minutes.minutes
  end

  def duration_display
    return "Unknown" unless duration_minutes

    hours = duration_minutes / 60
    minutes = duration_minutes % 60

    if hours > 0 && minutes > 0
      "#{hours}h #{minutes}m"
    elsif hours > 0
      "#{hours}h"
    else
      "#{minutes}m"
    end
  end

  def status_display
    status&.titleize&.gsub("_", " ")
  end

  def appointment_type_display
    case appointment_type
    when "follow_up"
      "Follow-up"
    when "no_show"
      "No Show"
    else
      appointment_type&.titleize
    end
  end

  def can_be_confirmed?
    status == "scheduled"
  end

  def can_be_cancelled?
    %w[scheduled confirmed].include?(status)
  end

  def can_be_completed?
    %w[confirmed].include?(status)
  end

  def can_be_rescheduled?
    %w[scheduled confirmed].include?(status)
  end

  def is_upcoming?
    appointment_date && appointment_date > Time.current
  end

  def is_past?
    appointment_date && appointment_date <= Time.current
  end

  def is_today?
    appointment_date && appointment_date.to_date == Date.current
  end

  def is_emergency?
    appointment_type == "emergency"
  end

  def is_routine?
    appointment_type == "routine"
  end

  def is_long_appointment?
    duration_minutes && duration_minutes >= 60
  end

    def time_until_appointment
    return nil unless appointment_date && is_upcoming?

    diff = appointment_date - Time.current
    days = (diff / 1.day).to_i
    hours = ((diff % 1.day) / 1.hour).to_i
    minutes = ((diff % 1.hour) / 1.minute).to_i

    if days > 0
      "#{days} day#{'s' if days != 1}"
    elsif hours > 0
      "#{hours} hour#{'s' if hours != 1}"
    else
      "#{minutes} minute#{'s' if minutes != 1}"
    end
  end

  def confirm!
    update!(status: "confirmed")
  end

  def cancel!(reason = nil)
    update!(status: "cancelled", notes: [ notes, "Cancelled: #{reason}" ].compact.join(" - "))
  end

  def complete!
    update!(status: "completed")
  end

  def mark_no_show!
    update!(status: "no_show")
  end

  def start_appointment!
    update!(status: "in_progress")
  end

  private

  def set_default_values
    self.status ||= "scheduled"
    self.duration_minutes ||= 30
    self.appointment_type ||= "routine"
  end

  def handle_status_changes
    if status_changed?
      # Handle any status change logic here if needed
    end
  end

  def appointment_date_must_be_in_reasonable_future
    return unless appointment_date

    if appointment_date > 2.years.from_now
      errors.add(:appointment_date, "cannot be more than 2 years in the future")
    end
  end

  def appointment_date_cannot_be_too_far_in_past
    return unless appointment_date

    if appointment_date < 1.hour.ago
      errors.add(:appointment_date, "cannot be more than 1 hour in the past")
    end
  end



  def no_double_booking_for_doctor
    return unless doctor_id && appointment_date && duration_minutes

    # Check for overlapping appointments for the same doctor
    appointment_start = appointment_date
    appointment_end = appointment_date + duration_minutes.minutes

    overlapping = Appointment.where(doctor_id: doctor_id)
                            .where.not(id: id) # Exclude current appointment for updates
                            .where.not(status: [ "cancelled", "no_show" ])
                            .where(
                              "appointment_date < ? AND (appointment_date + INTERVAL '1 minute' * duration_minutes) > ?",
                              appointment_end,
                              appointment_start
                            )

    if overlapping.exists?
      errors.add(:appointment_date, "conflicts with another appointment for this doctor")
    end
  end

  def reasonable_appointment_hours
    return unless appointment_date

    hour = appointment_date.hour
    day_of_week = appointment_date.wday

    # Business hours: Monday-Friday 7 AM - 6 PM, Saturday 8 AM - 2 PM
    if day_of_week == 0 # Sunday
      errors.add(:appointment_date, "appointments cannot be scheduled on Sundays")
    elsif day_of_week == 6 # Saturday
      unless (8..14).include?(hour)
        errors.add(:appointment_date, "Saturday appointments must be between 8 AM and 2 PM")
      end
    else # Monday-Friday
      unless (7..18).include?(hour)
        errors.add(:appointment_date, "weekday appointments must be between 7 AM and 6 PM")
      end
    end
  end
end
