class AddNameAndDescriptionToMeasurementImport < ActiveRecord::Migration
  def change
    add_column :measurement_imports, :name, :string

    add_column :measurement_imports, :description, :text

  end
end
