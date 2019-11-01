# frozen_string_literal: true

class AddAutoApproveRulesToMeasruementImports < ActiveRecord::Migration
  def up
    add_column :measurement_imports, :auto_apprv_no_high_cpm, :boolean
    add_column :measurement_imports, :auto_apprv_gps_validity, :boolean
    add_column :measurement_imports, :auto_apprv_frequent_bgeigie_id, :boolean
    add_column :measurement_imports, :auto_apprv_good_bgeigie_id, :boolean
  end

  def down
    remove_column :measurement_imports, :auto_apprv_no_high_cpm
    remove_column :measurement_imports, :auto_apprv_gps_validity
    remove_column :measurement_imports, :auto_apprv_frequent_bgeigie_id
    remove_column :measurement_imports, :auto_apprv_good_bgeigie_id
  end
end
