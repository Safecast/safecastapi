# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120711175214) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "bgeigie_logs", :force => true do |t|
    t.string   "device_tag"
    t.string   "device_serial_id"
    t.datetime "captured_at"
    t.integer  "cpm"
    t.integer  "counts_per_five_seconds"
    t.integer  "total_counts"
    t.string   "cpm_validity"
    t.float    "latitude_nmea"
    t.string   "north_south_indicator"
    t.float    "longitude_nmea"
    t.string   "east_west_indicator"
    t.float    "altitude"
    t.string   "gps_fix_indicator"
    t.float    "horizontal_dilution_of_precision"
    t.string   "gps_fix_quality_indicator"
    t.datetime "created_at",                                    :default => '1970-01-01 00:00:00', :null => false
    t.datetime "updated_at",                                    :default => '1970-01-01 00:00:00', :null => false
    t.integer  "bgeigie_import_id"
    t.point    "computed_location",                :limit => 0,                                                    :srid => 4326, :geographic => true
    t.string   "md5sum"
  end

  add_index "bgeigie_logs", ["md5sum"], :name => "index_bgeigie_logs_on_md5sum", :unique => true

  create_table "configurables", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "configurables", ["name"], :name => "index_configurables_on_name"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "devices", :force => true do |t|
    t.string   "manufacturer"
    t.string   "model"
    t.string   "sensor"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "serial_number"
  end

  create_table "drive_logs", :force => true do |t|
    t.integer  "drive_import_id"
    t.datetime "reading_date"
    t.float    "reading_value"
    t.integer  "unit_id"
    t.float    "alt_reading_value"
    t.integer  "alt_unit_id"
    t.integer  "rolling_count"
    t.integer  "total_count"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "gps_quality_indicator"
    t.integer  "satellite_num"
    t.float    "gps_precision"
    t.float    "gps_altitude"
    t.string   "gps_device_name"
    t.string   "measurement_type"
    t.string   "zoom_7_grid"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.point    "location",              :limit => 0,                 :srid => 4326, :geographic => true
    t.string   "md5sum"
  end

  add_index "drive_logs", ["drive_import_id"], :name => "index_drive_logs_on_measurement_import_id"
  add_index "drive_logs", ["md5sum"], :name => "index_drive_logs_on_md5sum", :unique => true

  create_table "maps", :force => true do |t|
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
    t.integer  "device_id"
    t.string   "name"
  end

  add_index "maps", ["device_id"], :name => "index_maps_on_device_id"
  add_index "maps", ["user_id"], :name => "index_maps_on_user_id"

  create_table "maps_measurements", :id => false, :force => true do |t|
    t.integer "map_id"
    t.integer "measurement_id"
  end

  create_table "measurement_imports", :force => true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.string   "md5sum"
    t.string   "type"
    t.string   "status"
    t.integer  "measurements_count"
    t.integer  "map_id"
    t.text     "status_details"
    t.boolean  "approved",           :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "name"
    t.text     "description"
    t.integer  "lines_count"
    t.text     "credits"
    t.integer  "height"
    t.string   "orientation"
    t.text     "cities"
  end

  create_table "measurements", :force => true do |t|
    t.integer  "user_id"
    t.float    "value"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "unit"
    t.point    "location",              :limit => 0,                 :srid => 4326, :geographic => true
    t.string   "location_name"
    t.integer  "device_id"
    t.integer  "original_id"
    t.datetime "expired_at"
    t.integer  "replaced_by"
    t.integer  "updated_by"
    t.integer  "measurement_import_id"
    t.string   "md5sum"
    t.datetime "captured_at"
    t.integer  "height"
    t.string   "surface"
    t.string   "radiation"
  end

  add_index "measurements", ["device_id"], :name => "index_measurements_on_device_id"
  add_index "measurements", ["location"], :name => "index_measurements_on_location", :spatial => true
  add_index "measurements", ["md5sum"], :name => "index_measurements_on_md5sum", :unique => true
  add_index "measurements", ["measurement_import_id"], :name => "index_measurements_on_measurement_import_id"
  add_index "measurements", ["original_id"], :name => "index_measurements_on_original_id"
  add_index "measurements", ["user_id"], :name => "index_measurements_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "name"
    t.string   "time_zone"
    t.boolean  "moderator",                             :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
