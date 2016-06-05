Fabricator(:bgeigie_import) do
  source { sequence(:source) { |n| Rails.root.join("spec/fixtures/bgeigie#{n % 6}.log").open(File::RDONLY) } }
  user
end
