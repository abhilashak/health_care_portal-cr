class HealthcareFacilitiesController < ApplicationController
  before_action :require_facility_access, only: [ :dashboard ]

  # GET /facility/dashboard
  def dashboard
    @facility = current_user
    @total_doctors = @facility.hospital_doctors.count + @facility.clinic_doctors.count
    @recent_appointments = Appointment.joins(:doctor)
                                     .where(doctors: { hospital_id: @facility.id })
                                     .or(Appointment.joins(:doctor).where(doctors: { clinic_id: @facility.id }))
                                     .order(appointment_date: :desc)
                                     .limit(10)
  end

  private

  def require_facility_access
    require_user_type("facility")
  end
end
