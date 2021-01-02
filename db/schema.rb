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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_11_191041) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "admins", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "bgeigie_logs", id: :serial, force: :cascade do |t|
    t.string "device_tag", limit: 255
    t.string "device_serial_id", limit: 255
    t.datetime "captured_at"
    t.integer "cpm"
    t.integer "counts_per_five_seconds"
    t.integer "total_counts"
    t.string "cpm_validity", limit: 255
    t.decimal "latitude_nmea"
    t.string "north_south_indicator", limit: 255
    t.decimal "longitude_nmea"
    t.string "east_west_indicator", limit: 255
    t.float "altitude"
    t.string "gps_fix_indicator", limit: 255
    t.float "horizontal_dilution_of_precision"
    t.string "gps_fix_quality_indicator", limit: 255
    t.datetime "created_at", default: "1970-01-01 00:00:00", null: false
    t.datetime "updated_at", default: "1970-01-01 00:00:00", null: false
    t.integer "bgeigie_import_id"
    t.geography "computed_location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "md5sum"
    t.index ["bgeigie_import_id"], name: "idx_bgeigie_logs_bgeigie_import_id_index"
    t.index ["bgeigie_import_id"], name: "index_bgeigie_logs_on_bgeigie_import_id"
    t.index ["device_serial_id"], name: "idx_bgeigie_logs_device_serial_id_index"
    t.index ["device_serial_id"], name: "index_bgeigie_logs_on_device_serial_id"
    t.index ["md5sum"], name: "index_bgeigie_logs_on_md5sum", unique: true
  end

  create_table "configurables", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "value", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_configurables_on_name"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "queue", limit: 255
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "device_stories", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "device_urn", null: false
    t.jsonb "metadata"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "device_id"
    t.geography "last_location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "last_values"
    t.datetime "last_seen"
    t.string "last_location_name"
    t.string "custodian_name"
    t.index ["device_urn"], name: "index_device_stories_on_device_urn"
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.string "manufacturer", limit: 255
    t.string "model", limit: 255
    t.string "sensor", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "measurements_count"
  end

  create_table "drive_logs", id: :serial, force: :cascade do |t|
    t.integer "drive_import_id"
    t.datetime "reading_date"
    t.float "reading_value"
    t.integer "unit_id"
    t.float "alt_reading_value"
    t.integer "alt_unit_id"
    t.integer "rolling_count"
    t.integer "total_count"
    t.float "latitude"
    t.float "longitude"
    t.integer "gps_quality_indicator"
    t.integer "satellite_num"
    t.float "gps_precision"
    t.float "gps_altitude"
    t.string "gps_device_name"
    t.string "measurement_type"
    t.string "zoom_7_grid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "md5sum"
    t.index ["drive_import_id"], name: "index_drive_logs_on_measurement_import_id"
    t.index ["md5sum"], name: "index_drive_logs_on_md5sum", unique: true
  end

  create_table "ioslastexport", id: false, force: :cascade do |t|
    t.integer "lastmaxid"
    t.datetime "exportdate"
  end

  create_table "maps", id: :serial, force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "device_id"
    t.string "name", limit: 255
    t.index ["device_id"], name: "index_maps_on_device_id"
    t.index ["user_id"], name: "index_maps_on_user_id"
  end

  create_table "maps_measurements", id: false, force: :cascade do |t|
    t.integer "map_id"
    t.integer "measurement_id"
  end

  create_table "measurement_import_logs", id: :serial, force: :cascade do |t|
    t.integer "measurement_import_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

# Could not dump table "measurement_imports" because of following StandardError
#   Unknown type 'measurement_imports_subtype' for column 'subtype'

  create_table "measurements", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.float "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "unit"
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "location_name"
    t.integer "device_id"
    t.integer "original_id"
    t.datetime "expired_at"
    t.integer "replaced_by"
    t.integer "updated_by"
    t.integer "measurement_import_id"
    t.string "md5sum", limit: 255
    t.datetime "captured_at"
    t.integer "height"
    t.string "surface", limit: 255
    t.string "radiation", limit: 255
    t.string "devicetype_id", limit: 255
    t.integer "sensor_id"
    t.integer "station_id"
    t.integer "channel_id"
    t.index ["captured_at", "unit", "device_id"], name: "idx_measurements_captured_at_unit_device_id_device_id_not_null", where: "(device_id IS NOT NULL)"
    t.index ["captured_at", "unit", "device_id"], name: "index_measurements_on_captured_at_and_unit_and_device_id", where: "(device_id IS NOT NULL)"
    t.index ["captured_at"], name: "index_measurements_on_captured_at"
    t.index ["device_id"], name: "index_measurements_on_device_id"
    t.index ["location"], name: "index_measurements_on_location", using: :gist
    t.index ["md5sum"], name: "index_measurements_on_md5sum", unique: true
    t.index ["measurement_import_id"], name: "index_measurements_on_measurement_import_id"
    t.index ["original_id"], name: "index_measurements_on_original_id"
    t.index ["unit"], name: "index_measurements_on_unit"
    t.index ["user_id", "captured_at"], name: "index_measurements_on_user_id_and_captured_at"
    t.index ["user_id"], name: "index_measurements_on_user_id"
    t.index ["value", "device_id"], name: "idx_measurements_value_device_id_device_id_not_null", where: "(device_id IS NOT NULL)"
    t.index ["value", "device_id"], name: "index_measurements_on_value_and_device_id", where: "(device_id IS NOT NULL)"
    t.index ["value", "unit"], name: "index_measurements_on_value_and_unit"
  end

  create_table "rails_admin_histories", id: :serial, force: :cascade do |t|
    t.text "message"
    t.string "username", limit: 255
    t.integer "item"
    t.string "table", limit: 255
    t.integer "month", limit: 2
    t.bigint "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item", "table", "month", "year"], name: "index_rails_admin_histories"
  end

  create_table "uploader_contact_histories", id: :serial, force: :cascade do |t|
    t.integer "bgeigie_import_id"
    t.integer "administrator_id", null: false
    t.string "previous_status", limit: 255, null: false
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "authentication_token", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 255
    t.string "time_zone", limit: 255
    t.boolean "moderator", default: false
    t.integer "measurements_count"
    t.string "default_locale", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "authentication_token_created_at"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
