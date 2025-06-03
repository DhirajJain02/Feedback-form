module PhoneNumberHelper
  def format_phone_number(number)
    return nil if number.blank?

    number = number.strip

    if number.start_with?('+') && number.length >= 10
      number
    else
      digits = number.gsub(/\D/, '') # Remove non-digits only after checking '+'

      if digits.length == 10
        "+91#{digits}"
      elsif digits.length == 12 && digits.start_with?("91")
        "+#{digits}"
      else
        nil
      end
    end
  end
end
