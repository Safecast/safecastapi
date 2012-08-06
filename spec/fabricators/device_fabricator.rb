Fabricator(:device) do
  manufacturer    'Safecast'
  model           'bGeigie'
  sensors         { Fabricate.sequence(:sensor) }
end
