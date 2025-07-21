class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has()
  allow_browser versions: :modern

  # Include authentication helpers
  include ApplicationHelper

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

  def debug_session
    render json: {
      session_data: {
        user_id: session[:user_id],
        user_type: session[:user_type]
      },
      authentication_status: {
        logged_in: logged_in?,
        current_user_email: current_user&.email,
        current_user_type: current_user_type
      },
      cookie_info: {
        session_cookie_exists: request.cookies.key?("_health_care_portal_session"),
        session_cookie_size: request.cookies["_health_care_portal_session"]&.length
      }
    }
  end
end
