class DashboardController < ApplicationController
  PER_PAGE = 10

  def index

    @total_submissions = FeedbackDetail.count
    @new_today = FeedbackDetail.where("created_at >= ?", Date.today).count
    @pending_issues = FeedbackDetail.where(status: "pending").count
    @resolved_issues = FeedbackDetail.where(status: "resolved").count
    @high_priority_pending = FeedbackDetail.where(status: "pending", urgency: "High Priority").count

    @feedbacks_by_category = FeedbackDetail.group(:category).count
    @urgency_levels = FeedbackDetail.group(:urgency).count
    # @recent_feedbacks = FeedbackDetail
    #                       .order(created_at: :desc)
    #                       .paginate(page: params[:page], per_page: PER_PAGE)
    # @recent_feedbacks = FeedbackDetail.order(created_at: :desc).limit(10)
    # @recent_feedbacks = FeedbackDetail.order(created_at: :desc).page(params[:page]).per(10)

    @category_data = FeedbackDetail.group(:category).count
    @urgency_data = FeedbackDetail.group(:urgency).count

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

  end

  def export_csv
    @feedbacks = FeedbackDetail.all
    respond_to do |format|
      format.csv { send_data @feedbacks.to_csv, filename: "feedbacks-#{Date.today}.csv" }
    end
  end
end
