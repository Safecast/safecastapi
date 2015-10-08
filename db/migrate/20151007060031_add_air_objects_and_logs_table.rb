class AddAirObjectsAndLogsTable < ActiveRecord::Migration
  def change
    remove_column :measurements, :sensor_id
    remove_column :measurements, :channel_id
    remove_column :measurements, :station_id
    remove_column :measurements, :devicetype_id
    
    add_column :devices, :device_group_id, :integer
    add_column :devices, :unit,            :string
    
    create_table "device_groups", :force => true do |t|
      t.integer  "device_unit_id",      :null => false
      t.string   "manufacturer"
      t.string   "model"
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
      t.datetime "created_at"
    end
    
    create_table "device_units", :force => true do |t|
      t.integer  "station_id",         :null => false
      t.string   "manufacturer"
      t.string   "model"
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
      t.datetime "created_at"
    end
    
    create_table "stations", :force => true do |t|
      t.string   "manufacturer"
      t.string   "model"
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
      t.datetime "created_at"
    end
    
    create_table "air_logs", :force => true do |t|
      t.string   "device_tag"
      t.string   "device_serial_id"
      t.integer  "device_id"
      t.datetime "captured_at"
      t.float    "measurement"
      t.string   "unit"
      t.float    "latitude"
      t.float    "longitude"
      t.float    "altitude"
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.integer  "air_import_id"
      t.spatial  "computed_location",                   :limit => {:srid=>4326, :type=>"point", :geographic=>true}
      t.string   "md5sum"
    end 
  end
end