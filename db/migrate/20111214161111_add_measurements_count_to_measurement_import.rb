class AddMeasurementsCountToMeasurementImport < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :measurements_count, :integer
  end
end
