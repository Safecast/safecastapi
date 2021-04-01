class AddStatusDetailsToMeasurementImport < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :status_details, :text

  end
end
