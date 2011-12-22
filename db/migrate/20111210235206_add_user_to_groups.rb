class AddUserToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :user_id, :integer
    
    add_index :groups, :user_id
  end
end
