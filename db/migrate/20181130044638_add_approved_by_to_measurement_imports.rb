# frozen_string_literal: true

class AddApprovedByToMeasurementImports < ActiveRecord::Migration
  def up
    add_column :measurement_imports, :approved_by, :string
  end

  def down
    remove_column :measurement_imports, :approved_by
  end
end
