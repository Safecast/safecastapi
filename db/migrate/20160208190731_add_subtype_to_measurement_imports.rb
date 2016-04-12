class AddSubtypeToMeasurementImports < ActiveRecord::Migration
  def change
  	add_column :measurement_imports, :subtype, :text
  end
end
