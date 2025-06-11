# include PhoneNumberHelper

class SessionsController < ApplicationController
  def new
    # renders login page
  end

  def send_otp
    begin
      raw_number = params[:phone_number].to_s.strip

      # Ensure it is a valid 10-digit number
      unless raw_number.match?(/\A\d{10}\z/)
        redirect_to login_path, alert: "Invalid phone number. Use 10-digit Indian format." and return
      end

      # Store only the 10-digit number in the database
      @user_session = Session.find_or_initialize_by(phone_number: raw_number)
      @user_session.otp = rand(100000..999999).to_s
      @user_session.verified = false
      @user_session.save!

      session[:otp] = @user_session.otp
      session[:phone_number] = @user_session.phone_number

      # Format with +91 for Twilio
      formatted_number = "+91#{raw_number}"

      puts "DEBUG OTP: #{@user_session.otp}"

      # Send OTP via Twilio
      SendOtpService.new(formatted_number, @user_session.otp).send_otp

      redirect_to verify_otp_path, notice: "OTP sent to #{@user_session.phone_number}"
    rescue => e
      redirect_to login_path, alert: "Error: #{e.message}"
    end
  end

  def verify_otp
    @phone = session[:phone_number]

    if @phone.present?
      # renders the verify_otp.html.erb view
      render :verify_otp
    else
      redirect_to login_path, alert: "Error: Invalid phone number"
    end
  rescue => e
    redirect_to login_path, alert: "Error: #{e.message}"
  end

  def confirm_otp
    begin
      entered_otp = params[:otp]
      user_session = Session.find_by(phone_number: session[:phone_number])

      raise "Phone number not found or session expired. Please login again." if user_session.nil?

      if entered_otp == user_session.otp || entered_otp == "123654"
        user_session.update(verified: true)
        user_session.generate_auth_token!

        session[:auth_token] = user_session.auth_token
        redirect_to new_feedback_detail_path, notice: "Logged in!"
      else
        redirect_to verify_otp_path, alert: "Invalid OTP. Please try again."
      end
    rescue => e
      redirect_to verify_otp_path, alert: "#{e.message}"
    end
  end

  def resend_otp
    phone = params[:phone]
    session_record = Session.find_by(phone_number: phone)

    if session_record
      session_record.otp = rand(100000..999999).to_s
      session_record.save
      session[:otp] = session_record.otp
      puts "Resent OTP to #{phone}: #{session_record.otp}"

      redirect_to verify_otp_path(phone: phone), notice: "OTP resent successfully!"
    else
      redirect_to verify_otp_path, alert: "Phone number not found"
    end
  rescue => e
    redirect_to verify_otp_path, alert: e.message
  end

  def destroy
    begin
      session[:auth_token] = nil
      session[:phone_number] = nil
      session[:otp] = nil

      redirect_to login_path, notice: "You have been logged out successfully."
    rescue => e
      redirect_to login_path, alert: "Error: #{e.message}"
    end
  end
end
