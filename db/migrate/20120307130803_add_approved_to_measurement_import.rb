class AddApprovedToMeasurementImport < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :approved, :boolean, :default => false

  end
end
