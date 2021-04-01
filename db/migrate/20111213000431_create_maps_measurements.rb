class CreateMapsMeasurements < ActiveRecord::Migration
  def change
    create_table :maps_measurements, :id => false do |t|
      t.references :map, :measurement
    end
  end
end
