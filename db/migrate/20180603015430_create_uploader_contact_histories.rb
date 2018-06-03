class CreateUploaderContactHistories < ActiveRecord::Migration
  def change
    create_table :uploader_contact_histories do |t|
      t.references :bgeigie_import
      t.integer :administrator_id, null: false
      t.string :previous_status, null: false
      t.text :content
      t.timestamps
    end
  end
end
