Jbuilder.encode do |json|
  json.arra!(@bgeigie_import.bgeigie_logs) do |bgeigie_log|
    json.lat bgeigie_log.latitude
    json.lng bgeigie_log.longitude
    json.cpm bgeigie_log.cpm
  end
end