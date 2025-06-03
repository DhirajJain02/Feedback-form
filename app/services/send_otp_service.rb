class SendOtpService
  def initialize(phone_number, otp)
    @phone_number = phone_number
    @otp = otp
  end

  def call
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    client.messages.create(
      messaging_service_sid: ENV['TWILIO_MESSAGING_SERVICE_SID'],
      to: @phone_number,
      body: "Your OTP code is #{@otp}"
    )
  end
end
