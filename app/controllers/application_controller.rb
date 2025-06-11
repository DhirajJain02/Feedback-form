class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authenticate_with_token!
    begin
      token = request.headers["Authorization"]&.split(" ")&.last || session[:auth_token]
      @current_user_session = Session.find_by(auth_token: token)
      unless @current_user_session&.token_valid?(token)
        respond_to do |format|
          format.html { redirect_to login_path, alert: "Unauthorized access" }
          format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
        end
      end
    rescue => e
      redirect_to login_path, alert: "Something went wrong: #{e.message}"
    end
  end

  def current_user_session
    @current_user_session
  end
  helper_method :current_user_session
end
