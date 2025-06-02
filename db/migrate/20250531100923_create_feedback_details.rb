class CreateFeedbackDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :feedback_details do |t|
      t.string :category
      t.text :description
      t.string :location_address
      t.string :urgency
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
