# frozen_string_literal: true

class AddVersionNumberToMeasurementImport < ActiveRecord::Migration
  def up
    add_column :measurement_imports, :version, :string
  end

  def down
    remove_column :measurement_imports, :version
  end
end
