class AdminsController < ApplicationController
  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        session[:admin_id] = @admin.id
        format.html do
          redirect_to admin_login_path, notice: "Admin created successfully. Please log in."
        end
        format.json do
          render json: { message: "Admin created successfully", admin: @admin }, status: :created
        end
      else
        format.html do
          render :new, status: :unprocessable_entity
        end
        format.json do
          render json: { errors: @admin.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  rescue => e
    respond_to do |format|
      format.html do
        flash.now[:alert] = "Something went wrong. Please try again."
        render :new, status: 500
      end
      format.json do
        render json: { error: "Internal Server Error", details: e.message }, status: 500
      end
    end
  end

  def login
    # just renders login form
  rescue => e
    flash.now[:alert] = "Something went wrong. Please try again."
    render plain: "Error: #{e.message}", status: 500
  end

  def login_create
    respond_to do |format|
      begin
        admin = Admin.find_by(email: params[:email])

        if admin&.authenticate(params[:password])
          session[:admin_id] = admin.id

          format.html do
            redirect_to dashboard_index_path, notice: "Logged in successfully"
          end
          format.json do
            render json: { message: "Logged in successfully", admin_id: admin.id }, status: :ok
          end
        else
          format.html do
            flash.now[:alert] = "Invalid email or password"
            render :login, status: :unauthorized
          end
          format.json do
            render json: { error: "Invalid email or password" }, status: :unauthorized
          end
        end
      rescue => e
        format.html do
          flash.now[:alert] = "Something went wrong. Please try again."
          render :login, status: 500
        end
        format.json do
          render json: { error: "Internal Server Error", details: e.message }, status: 500
        end
      end
    end
  end

  def logout
    begin
      session[:admin_id] = nil
      redirect_to admin_login_path, notice: "Logged out successfully"
    rescue => e
      flash[:alert] = "Something went wrong while logging out."
      redirect_to admin_login_path, status: 500
    end
  end

  private

  def admin_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end
end
