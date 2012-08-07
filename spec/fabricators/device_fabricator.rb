Fabricator(:device) do
  manufacturer    'Safecast'
  model           'bGeigie'
  sensors(count:1) { |ix| Fabricate(:sensor) }
end
