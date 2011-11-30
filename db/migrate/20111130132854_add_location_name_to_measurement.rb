class AddLocationNameToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :location_name, :string
  end
end
