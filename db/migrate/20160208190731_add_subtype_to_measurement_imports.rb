class AddSubtypeToMeasurementImports < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :subtype, :string, default: 'None', null: false
    add_index :measurement_imports, :subtype
    add_index :measurement_imports, [ :id, :subtype ]
  end
end
