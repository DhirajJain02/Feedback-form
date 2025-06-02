class SessionsController < ApplicationController
  def new
    # renders login page
  end

  def send_otp
    begin
      @user_session = UserSession.find_or_initialize_by(phone_number: params[:phone_number])
      @user_session.otp = rand(100000..999999).to_s
      @user_session.verified = false
      @user_session.save!

      session[:otp] = @user_session.otp
      session[:phone_number] = @user_session.phone_number

      puts "DEBUG OTP: #{@user_session.otp}"

      redirect_to verify_otp_path, notice: "OTP sent successfully!"
    rescue => e
      redirect_to login_path, alert: "#{e.message}"
    end

  end

  def verify_otp
    @phone = session[:phone_number]
  end

  def confirm_otp
    begin
      entered_otp = params[:otp]
      user_session = UserSession.find_by(phone_number: session[:phone_number])

      # Raise error if user_session not found
      raise "Phone number not found or session expired. Please login again." if user_session.nil?

      stored_otp = user_session&.otp

      Rails.logger.debug "Entered OTP: #{entered_otp}"
      Rails.logger.debug "Stored OTP: #{stored_otp}"

      if entered_otp == stored_otp
        user_session.update(verified: true)
        redirect_to new_feedback_detail_path
      else
        redirect_to verify_otp_path, alert: "Invalid OTP. Please try again."
      end
    rescue => e
      redirect_to verify_otp_path, alert: "#{e.message}"
    end
  end

  def resend_otp
    begin
      phone = params[:phone]
      session_record = UserSession.find_by(phone_number: phone)

      if session_record
        session_record.otp = rand(100000..999999).to_s
        session_record.save
        session[:otp] = session_record.otp
        puts "Resent OTP to #{phone}: #{session_record.otp}"
      end
      redirect_to verify_otp_path(phone: phone), notice: "OTP resend successfully!"
    end
  rescue => e
    redirect_to verify_otp_path, alert: "#{e.message}"
  end
end
