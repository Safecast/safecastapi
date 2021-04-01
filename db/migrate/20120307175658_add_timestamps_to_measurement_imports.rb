class AddTimestampsToMeasurementImports < ActiveRecord::Migration
  def change
    change_table :measurement_imports do |t|
        t.timestamps
    end
  end
end
