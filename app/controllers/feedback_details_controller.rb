class FeedbackDetailsController < ApplicationController
  before_action :authenticate_with_token!
  def new
    @feedback_detail = FeedbackDetail.new
  end

  def create
    begin
    @feedback_detail = current_user_session.feedback_details.new(feedback_detail_params)

    if @feedback_detail.save
      redirect_to thank_you_path
    else
      render :new, status: :unprocessable_entity
    end
    rescue => e
      redirect_to feedback_details_path, alert: "Error: #{e.message}"
    end
  end

  def thank_you
  end

  private

  def feedback_detail_params
    params.require(:feedback_detail).permit(:category, :description, :location_address, :urgency, :name, :email, :image)
  end
end
