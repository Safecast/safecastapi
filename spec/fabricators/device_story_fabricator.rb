# frozen_string_literal: true

Fabricator(:device_story) do
  device_urn { sequence(:device_urn) { |i| "fabricated:#{i}" } }
  custodian_name { "#{Random.rand(20..100)} name" }
  metadata do
    { 'last_seen' => Time.current,
      'last_values' => Random.rand(20..100).to_s,
      'last_lon' => '139.719176667',
      'last_lat' => '35.64214' }
  end
  last_location { 'POINT(139.719176667 35.64214)' }
end
