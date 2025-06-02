class AddStatusToFeedbackDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :feedback_details, :status, :string, default: "pending"

    # Ensure existing records are updated too
    reversible do |dir|
      dir.up do
        FeedbackDetail.update_all(status: "pending")
      end
    end
  end
end
