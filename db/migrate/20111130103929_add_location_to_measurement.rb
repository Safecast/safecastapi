class AddLocationToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :location, :point, :geographic => true
  end
end
