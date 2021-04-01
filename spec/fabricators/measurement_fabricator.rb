# frozen_string_literal: true

Fabricator(:measurement) do
  value '380'
  unit 'cpm'
  longitude '56'
  latitude '-6'
  captured_at { Time.current }
end
