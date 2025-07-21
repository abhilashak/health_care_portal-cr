module ApplicationHelper
  def format_phone_number(phone)
    return phone if phone.blank?

    # Remove any non-digit characters
    digits = phone.gsub(/\D/, "")

    # Format based on length
    case digits.length
    when 10
      "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}"
    when 11
      "+#{digits[0]} (#{digits[1..3]}) #{digits[4..6]}-#{digits[7..10]}"
    else
      phone
    end
  end
end
