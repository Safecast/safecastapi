class AddDefaultToBgeigieLog < ActiveRecord::Migration
  def up
    change_column :bgeigie_logs, :created_at, :datetime, :default => '1 jan 1970'
    change_column :bgeigie_logs, :updated_at, :datetime, :default => '1 jan 1970'
  end
  
  def down
    change_column :bgeigie_logs, :created_at, :datetime
    change_column :bgeigie_logs, :updated_at, :datetime
    
  end
end