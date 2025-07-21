module ApplicationHelper
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
    end
  end

  def require_user_type(user_type)
    require_login
    unless current_user_type == user_type
      flash[:alert] = "You don't have permission to access this page."
      redirect_to root_path
    end
  end

  def format_phone_number(phone)
    return phone if phone.blank?

    # Remove all non-digit characters
    digits = phone.gsub(/\D/, "")

    # Format based on length
    case digits.length
    when 10
      # US format: (123) 456-7890
      "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}"
    when 11 && digits[0] == "1"
      # US format with country code: 1 (123) 456-7890
      "1 (#{digits[1..3]}) #{digits[4..6]}-#{digits[7..10]}"
    when 7
      # Local format: 123-4567
      "#{digits[0..2]}-#{digits[3..6]}"
    else
      # Return original if we can't format it
      phone
    end
  end
end
