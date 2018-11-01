class CreateUploaderContactHistories < ActiveRecord::Migration
  def change
    create_table :uploader_contact_histories do |t|
      t.references :bgeigie_import
      t.integer :administrator_id, null: false
      t.string :previous_status, null: false
      t.text :content
      t.timestamps
    end

    add_indexes_from_migrations
  end

  private

  def add_indexes_from_migrations
    # These are indexes found during updating rails to 4.2.
    # Names are different, but on same columns.
    # Could not create new migration, so put here to keep record
    # and be able to create indexes when creating new database.
    add_index :bgeigie_logs, :bgeigie_import_id
    add_index :bgeigie_logs, :device_serial_id
    add_index :measurements, [:captured_at, :unit, :device_id], where: 'device_id IS NOT NULL'
    add_index :measurements, [:value, :device_id], where: 'device_id IS NOT NULL'
  end
end
