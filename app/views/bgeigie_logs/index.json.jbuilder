# frozen_string_literal: true

json.array!(@bgeigie_import.bgeigie_logs) do |bgeigie_log|
  json.lat bgeigie_log.latitude
  json.lng bgeigie_log.longitude
  json.cpm bgeigie_log.cpm
  json.usv bgeigie_log.usv
  json.captured_at bgeigie_log.captured_at
end
