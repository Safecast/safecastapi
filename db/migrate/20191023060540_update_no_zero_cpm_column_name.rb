class UpdateNoZeroCpmColumnName < ActiveRecord::Migration
  def change
    rename_column :measurement_imports, :no_zero_cpm, :auto_apprv_no_zero_cpm
  end
end
