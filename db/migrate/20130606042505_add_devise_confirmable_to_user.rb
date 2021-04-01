class AddDeviseConfirmableToUser < ActiveRecord::Migration
  def up

    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime

    add_index :users, :confirmation_token

    User.update_all confirmed_at: Time.now
  end

  def down
    remove_index :users, :column => :confirmation_token

    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_token
  end
end
