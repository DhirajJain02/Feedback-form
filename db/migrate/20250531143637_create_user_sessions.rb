class CreateUserSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sessions do |t|
      t.string :phone_number
      t.string :otp
      t.boolean :verified

      t.timestamps
    end
  end
end
