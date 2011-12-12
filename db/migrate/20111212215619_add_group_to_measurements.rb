class AddGroupToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :group_id, :integer
  end
end
