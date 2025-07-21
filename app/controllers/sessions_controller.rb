class SessionsController < ApplicationController
  def new
    # Show login form
  end

  def create
    user_type = params[:user_type]
    email = params[:email]
    password = params[:password]

    user = authenticate_user(user_type, email, password)

    if user
      session[:user_id] = user.id
      session[:user_type] = user_type
      redirect_to dashboard_path(user_type), notice: "Welcome back, #{user.display_name}!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    session[:user_type] = nil
    redirect_to root_path, notice: "You have been logged out successfully."
  end

  private

  def authenticate_user(user_type, email, password)
    case user_type
    when "doctor"
      user = Doctor.find_by(email: email)
    when "patient"
      user = Patient.find_by(email: email)
    when "facility"
      user = HealthcareFacility.find_by(email: email)
    else
      return nil
    end

    user&.authenticate(password)
  end

  def dashboard_path(user_type)
    case user_type
    when "doctor"
      doctor_dashboard_path
    when "patient"
      patient_dashboard_path
    when "facility"
      facility_dashboard_path
    else
      root_path
    end
  end
end
