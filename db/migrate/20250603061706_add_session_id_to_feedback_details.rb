class AddSessionIdToFeedbackDetails < ActiveRecord::Migration[8.0]
  def change
    add_reference :feedback_details, :session, null: false, foreign_key: true
  end
end
