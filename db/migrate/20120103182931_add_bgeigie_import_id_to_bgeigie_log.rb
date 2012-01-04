class AddBgeigieImportIdToBgeigieLog < ActiveRecord::Migration
  def change
    add_column :bgeigie_logs, :bgeigie_import_id, :integer
  end
end
