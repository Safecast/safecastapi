class AddChecksumToBgeigieLogAndMeasurement < ActiveRecord::Migration
  def change
    add_column :bgeigie_logs, :md5sum, :string
    add_column :measurements, :md5sum, :string
    add_index :bgeigie_logs, :md5sum, :unique => true
    add_index :measurements, :md5sum, :unique => true
  end
end
