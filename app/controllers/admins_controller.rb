class AdminsController < ApplicationController
  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)

    if @admin.save
      session[:admin_id] = @admin.id
      redirect_to admin_login_path, notice: "Admin created successfully. Please log in."
    else
      render :new, status: :unprocessable_entity
    end
  rescue => e
    flash.now[:alert] = "Something went wrong. Please try again."
    render :new, status: 500
  end

  def login
    # just renders login form
  rescue => e
    flash.now[:alert] = "Something went wrong. Please try again."
    render plain: "Error: #{e.message}", status: 500
  end

  def login_create
    admin = Admin.find_by(email: params[:email])

    if admin&.authenticate(params[:password])
      session[:admin_id] = admin.id
      redirect_to dashboard_index_path, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :login, status: :unauthorized
    end
  rescue => e
    flash.now[:alert] = "Something went wrong. Please try again."
    render :login, status: 500
  end

  def logout
    session[:admin_id] = nil
    redirect_to admin_login_path, notice: "Logged out successfully"
  rescue => e
    flash[:alert] = "Something went wrong while logging out."
    redirect_to admin_login_path, status: 500
  end

  private

  def admin_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end
end
