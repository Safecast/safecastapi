class AddMapIdToMeasurementImport < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :map_id, :integer
  end
end
