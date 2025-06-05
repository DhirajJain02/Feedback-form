class FeedbackDetailsController < ApplicationController
  before_action :authenticate_with_token!
  def new
    @feedback_detail = FeedbackDetail.new
  end

  def create
    # @feedback_detail = FeedbackDetail.new(feedback_detail_params)
    @feedback_detail = current_user_session.feedback_details.new(feedback_detail_params)

    respond_to do |format|
      if @feedback_detail.save
        format.html do
          # flash[:notice] = "Feedback submitted successfully."
          redirect_to thank_you_path
        end
        format.json { render json: { message: "Feedback submitted successfully" }, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }

        format.json do
          render json: {
            errors: @feedback_detail.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  # def import_csv
  #   if params[:file].blank?
  #     redirect_to feedback_details_path, alert: "Please upload a CSV file."
  #     return
  #   end
  #
  #   csv_file = params[:file]
  #
  #   begin
  #     CSV.foreach(csv_file.path, headers: true) do |row|
  #       FeedbackDetail.create!(row.to_hash)
  #     end
  #     redirect_to feedback_details_path, notice: "CSV imported successfully!"
  #   rescue => e
  #     redirect_to feedback_details_path, alert: "Failed to import CSV: #{e.message}"
  #   end
  # end

  def thank_you
  end
  private

  def feedback_detail_params
    params.require(:feedback_detail).permit(:category, :description, :location_address, :urgency, :name, :email, :image)
  end
end
