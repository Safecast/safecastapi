# frozen_string_literal: true

class AddWouldAutoApproveToMeasurementImports < ActiveRecord::Migration
  def up
    add_column :measurement_imports, :would_auto_approve, :boolean, default: false
  end

  def down
    remove_column :measurement_imports, :would_auto_approve
  end
end
