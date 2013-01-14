class ChangeHeightOnMeasurementImportFromIntegerToDecimal < ActiveRecord::Migration

  def up
    change_column :measurement_imports, :height, :decimal, :precision => 8, :scale => 2
  end

  def down
    change_column :measurement_imports, :height, :integer
  end
end
