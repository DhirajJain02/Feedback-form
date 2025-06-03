class AddUserSessionIdToFeedbackDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :feedback_details, :user_session_id, :integer
  end
end
