class AddAuthTokenToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :auth_token, :string
    add_column :sessions, :token_expires_at, :datetime
  end
end
