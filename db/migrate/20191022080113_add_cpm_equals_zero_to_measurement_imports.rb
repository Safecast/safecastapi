# frozen_string_literal: true

class AddCpmEqualsZeroToMeasurementImports < ActiveRecord::Migration
  def up
    add_column :measurement_imports, :auto_apprv_no_zero_cpm, :boolean
  end

  def down
    remove_column :measurement_imports, :auto_apprv_no_zero_cpm
  end
end
