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
end
