module ApplicationHelper
  # Include Pagy frontend helpers
  include Pagy::Frontend

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

  # Returns the appropriate dashboard path based on user type
  def dashboard_path_for_user
    case current_user_type
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

  # Returns a user-friendly display name for the current user
  def current_user_display_name
    current_user&.display_name || "Guest"
  end

  # Returns the appropriate CSS class for flash messages
  def flash_message_class(type)
    case type
    when "notice", "success"
      "bg-green-100 border-green-400 text-green-700"
    when "alert", "error"
      "bg-red-100 border-red-400 text-red-700"
    when "warning"
      "bg-yellow-100 border-yellow-400 text-yellow-700"
    when "info"
      "bg-blue-100 border-blue-400 text-blue-700"
    else
      "bg-gray-100 border-gray-400 text-gray-700"
    end
  end
end
