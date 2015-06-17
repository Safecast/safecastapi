Fabricator(:bgeigie_import) do
  source File.new(Rails.root.join("spec/fixtures/bgeigie#{Fabricate.sequence}.log"))
  user
end
