class AddAuthTokenToUserSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :user_sessions, :auth_token, :string
    add_column :user_sessions, :token_expires_at, :datetime
  end
end
