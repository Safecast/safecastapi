class IndexMeasurementsOnValueAndUnit < ActiveRecord::Migration
  def change
    add_index :measurements, [:value, :unit]
    add_index :measurements, :unit
  end
end
