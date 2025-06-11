class DashboardController < ApplicationController
  PER_PAGE = 10
  before_action :authenticate_admin!, except: [:resolve]

  def index
    begin
      @total_submissions = FeedbackDetail.count
      @new_today = FeedbackDetail.where("created_at >= ?", Date.today).count
      @pending_issues = FeedbackDetail.where(status: "pending").count
      @resolved_issues = FeedbackDetail.where(status: "resolved").count
      @high_priority_pending = FeedbackDetail.where(status: "pending", urgency: "High Priority").count

      @feedbacks_by_category = FeedbackDetail.group(:category).count
      @urgency_levels = FeedbackDetail.group(:urgency).count

      page_number = params[:page].to_i
      page_number = 1 if page_number < 1
      # Calculate total count of feedbacks (for computing total_pages later):
      total_count = FeedbackDetail.count
      # Compute how many pages are needed (ceiling division):
      @total_pages = (total_count.to_f / PER_PAGE).ceil
      # Clamp `page_number` so it cannot exceed @total_pages:
      page_number = @total_pages if page_number > @total_pages && @total_pages > 0
      # Calculate OFFSET (how many records to skip):
      offset_value = (page_number - 1) * PER_PAGE
      # Fetch exactly PER_PAGE records, ordered by created_at descending:
      @recent_feedbacks = FeedbackDetail
                            .order(created_at: :desc)
                            .offset(offset_value)
                            .limit(PER_PAGE)

      # Expose the current page to the view:
      @current_page = page_number
    rescue => e
      redirect_to admin_dashboard_path, alert: "Something went wrong. #{e.message}"
    end
  end

  def export_csv
    begin
      @feedbacks = FeedbackDetail.all
      respond_to do |format|
        format.csv { send_data @feedbacks.to_csv, filename: "feedbacks-#{Date.today}.csv" }
      end
    rescue => e
      flash.now[:alert] = "Something went wrong. #{e.message}"
      render index
    end
  end

  def resolve
    begin
      feedback = FeedbackDetail.find_by(id: params[:id])

      if feedback.nil?
        redirect_to dashboard_index_path, alert: "Feedback not found."
        return
      end

      if feedback.update(status: 'resolved')
        redirect_to dashboard_index_path, notice: "Ticket marked as resolved."
      else
        redirect_to dashboard_index_path, alert: "Could not mark as resolved."
      end
    rescue => e
      flash.now[:alert] = "Something went wrong. #{e.message}"
      render index
    end
  end

  private

  def authenticate_admin!
    unless session[:admin_id] && Admin.exists?(session[:admin_id])
      redirect_to admin_login_path, alert: "Please log in as admin to access the dashboard."
    end
  end
end
