Fabricator(:air_import) do
  source File.new(Rails.root.join("spec/fixtures/air#{Fabricate.sequence(:air_import_sequence)}.log"))
  user
end
