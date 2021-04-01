class AddDetailsToMeasurementImport < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :credits, :text

    add_column :measurement_imports, :height, :integer

    add_column :measurement_imports, :orientation, :string

    add_column :measurement_imports, :cities, :text

  end
end
