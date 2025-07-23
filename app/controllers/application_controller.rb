class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has()
  allow_browser versions: :modern

  # Include authentication helpers
  include Pagy::Backend

  # Make authentication methods available in views
  helper_method :logged_in?, :current_user, :current_user_type

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

    # Filter hospitals and clinics based on search with pagination
    @hospitals_pagy, @hospitals = if @hospital_search.present?
      pagy(Hospital.search_by_name_and_address(@hospital_search))
    else
      pagy(Hospital.all)
    end

    @clinics_pagy, @clinics = if @clinic_search.present?
      pagy(Clinic.search_by_name_and_address(@clinic_search))
    else
      pagy(Clinic.all)
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

  def current_user
    return nil unless session[:user_id] && session[:user_type]

    case session[:user_type]
    when "doctor"
      Doctor.find_by(id: session[:user_id])
    when "patient"
      Patient.find_by(id: session[:user_id])
    when "facility"
      HealthcareFacility.find_by(id: session[:user_id])
    end
  end

  def current_user_type
    session[:user_type]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "Please log in to access this page."
      redirect_to login_path
      nil
    end
  end

  def require_user_type(user_type)
    require_login
    return if performed? # Stop if a redirect was already performed

    unless current_user_type == user_type
      flash[:alert] = "You don't have permission to access this page."
      redirect_to root_path
      nil
    end
  end
end
