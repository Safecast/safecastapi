class AddExtraFieldsToMeasurementsTable < ActiveRecord::Migration
 def change
    add_column :measurements, :sensor_id, :integer

    add_column :measurements, :channel_id, :integer

    add_column :measurements, :station_id, :integer

    add_column :measurements, :devicetype_id, :string

  end
end
