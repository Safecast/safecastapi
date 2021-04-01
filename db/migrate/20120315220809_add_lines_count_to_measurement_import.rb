class AddLinesCountToMeasurementImport < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :lines_count, :integer

  end
end
