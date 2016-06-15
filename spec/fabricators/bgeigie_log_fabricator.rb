Fabricator(:bgeigie_log) do
  device_tag '$BGRDD'
  device_serial_id '002'
  captured_at { Time.current.strftime('%Y-%m-%dT%H:%M:%SZ') }
  cpm { Random.rand(20..100) }
  counts_per_five_seconds { |attrs| attrs[:cpm].div(12) }
  total_counts { |attrs| attrs[:cpm] }
  cpm_validity 'A'
  latitude_nmea 3538.5284
  north_south_indicator 'N'
  longitude_nmea 13943.1506
  east_west_indicator 'E'
  altitude { Random.rand(0..999) }
  gps_fix_indicator 'A'
  computed_location { 'POINT(139.719176667 35.64214)' }
end
