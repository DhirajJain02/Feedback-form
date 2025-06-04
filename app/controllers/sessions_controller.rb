include PhoneNumberHelper

class SessionsController < ApplicationController
  def new
    # renders login page
  end

  def send_otp
    begin
      # formatted_number = format_phone_number(params[:phone_number])
      #
      # if formatted_number.nil?
      #   redirect_to login_path, alert: "Invalid phone number. Please use +91XXXXXXXXXX or 10-digit format." and return
      # end
      #
      # @user_session = UserSession.find_or_initialize_by(phone_number: formatted_number)
      @user_session = Session.find_or_initialize_by(phone_number: params[:phone_number])
      @user_session.otp = rand(100000..999999).to_s
      @user_session.verified = false
      @user_session.save!

      session[:otp] = @user_session.otp
      session[:phone_number] = @user_session.phone_number

      puts "DEBUG OTP: #{@user_session.otp}"

      # SendOtpService.new(@user_session.phone_number, @user_session.otp).call
      redirect_to verify_otp_path, notice: "OTP sent to #{@user_session.phone_number}"
    rescue => e
      redirect_to login_path, alert: "Error: #{e.message}"
    end
  end

  def verify_otp
    @phone = session[:phone_number]
    unless @phone
      redirect_to login_path, alert: "Error: Invalid phone number"
    end
  end

  def confirm_otp
    begin
      entered_otp = params[:otp]
      user_session = Session.find_by(phone_number: session[:phone_number])

      raise "Phone number not found or session expired. Please login again." if user_session.nil?

      if entered_otp == user_session.otp
        user_session.update(verified: true)
        user_session.generate_auth_token!

        session[:auth_token] = user_session.auth_token
        respond_to do |format|
          format.html do
            redirect_to new_feedback_detail_path, notice: "Logged in!"
          end
          format.json do
            render json: {
              message: "OTP verified successfully",
              auth_token: user_session.auth_token,
              phone_number: user_session.phone_number
            }, status: :ok
          end
        end
      else
        respond_to do |format|
          format.html do
            redirect_to verify_otp_path, alert: "Invalid OTP. Please try again."
          end
          format.json do
            render json: { error: "Invalid OTP" }, status: :unauthorized
          end
        end
      end
    rescue => e
      respond_to do |format|
        format.html do
          redirect_to verify_otp_path, alert: "#{e.message}"
        end
        format.json do
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
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
