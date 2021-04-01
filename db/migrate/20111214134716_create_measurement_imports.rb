class CreateMeasurementImports < ActiveRecord::Migration
  def change
    create_table :measurement_imports do |t|
      t.integer :user_id
      t.string :source
      t.string :md5sum
      t.string :type
      t.string :status
    end
  end
end
