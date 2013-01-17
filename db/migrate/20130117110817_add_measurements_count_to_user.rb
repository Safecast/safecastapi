class AddMeasurementsCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :measurements_count, :integer
  end
end
