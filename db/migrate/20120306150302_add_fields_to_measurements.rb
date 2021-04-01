class AddFieldsToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :height, :integer

    add_column :measurements, :surface, :string

    add_column :measurements, :radiation, :string

  end
end
