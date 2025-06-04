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
      respond_to do |format|
        format.html do
          redirect_to verify_otp_path, notice: "OTP sent to #{@user_session.phone_number}"
        end
        format.json do
          render json: {
            message: "OTP sent successfully",
            phone_number: @user_session.phone_number,
            otp: @user_session.otp
          }, status: :ok
        end
      end

    rescue => e
      respond_to do |format|
        format.html do
          redirect_to login_path, alert: "Error: #{e.message}"
        end
        format.json do
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end

  def verify_otp
    @phone = session[:phone_number]

    respond_to do |format|
      if @phone.present?
        format.html do
          # renders the verify_otp.html.erb view
        end
        format.json do
          render json: {
            message: "Phone number found in session",
            phone_number: @phone
          }, status: :ok
        end
      else
        format.html do
          redirect_to login_path, alert: "Error: Invalid phone number"
        end
        format.json do
          render json: { error: "Invalid phone number." }, status: :unauthorized
        end
      end
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
    phone = params[:phone]
    session_record = UserSession.find_by(phone_number: phone)

    respond_to do |format|
      if session_record
        session_record.otp = rand(100000..999999).to_s
        session_record.save
        session[:otp] = session_record.otp
        puts "Resent OTP to #{phone}: #{session_record.otp}"

        format.html do
          redirect_to verify_otp_path(phone: phone), notice: "OTP resent successfully!"
        end
        format.json do
          render json: { message: "OTP resent successfully", phone_number: phone }, status: :ok
        end
      else
        format.html do
          redirect_to verify_otp_path, alert: "Phone number not found"
        end
        format.json do
          render json: { error: "Phone number not found" }, status: :not_found
        end
      end
    rescue => e
      format.html do
        redirect_to verify_otp_path, alert: e.message
      end
      format.json do
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    respond_to do |format|
      begin
        session[:auth_token] = nil
        session[:phone_number] = nil
        session[:otp] = nil

        format.html do
          redirect_to login_path, notice: "You have been logged out successfully."
        end

        format.json do
          render json: { message: "Logged out successfully" }, status: :ok
        end
      rescue => e
        format.html do
          redirect_to login_path, alert: "Error: #{e.message}"
        end

        format.json do
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end

end
