class AddAuthenticationTokenCreatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token_created_at, :datetime
  end
end
