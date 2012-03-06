class ChangeMfgToManufacturerOnDevice < ActiveRecord::Migration
  def change
    rename_column :devices, :mfg, :manufacturer
  end
end
