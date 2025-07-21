class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has()
  allow_browser versions: :modern

  # Basic index action for healthcare portal root route
  def index
    @hospitals_count = Hospital.count
    @clinics_count = Clinic.count
    @doctors_count = Doctor.count
    @patients_count = Patient.count
    @appointments_count = Appointment.count
    @upcoming_appointments = Appointment.upcoming.count

    # Search functionality
    @hospital_search = params[:hospital_search]
    @clinic_search = params[:clinic_search]

    # Filter hospitals and clinics based on search
    @hospitals = if @hospital_search.present?
      Hospital.where("name ILIKE ? OR address ILIKE ?", "%#{@hospital_search}%", "%#{@hospital_search}%")
    else
      Hospital.all
    end

    @clinics = if @clinic_search.present?
      Clinic.where("name ILIKE ? OR address ILIKE ?", "%#{@clinic_search}%", "%#{@clinic_search}%")
    else
      Clinic.all
    end
  end
end
