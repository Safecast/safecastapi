Fabricator(:user) do
  name 'Paul Campbell'
  email {"paul#{Fabricate.sequence(:email)}@rslw.com"}
  password 'monkeys'
  confirmed_at Time.now
end
