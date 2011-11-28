class AddUnitToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :unit, :string
  end
end
