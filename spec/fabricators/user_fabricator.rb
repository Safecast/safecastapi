Fabricator(:user) do
  name 'Paul Campbell'
  email {"paul#{Fabricate.sequence(:email)}@rslw.com"}
  password 'monkeys'
  confirmed_at Time.now
end

Fabricator(:admin_user, from: :user) do
  name 'Admin'
  email 'admin@safecast.org'
  password '111111'
  confirmed_at Time.current
  moderator true
end
