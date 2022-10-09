# frozen_string_literal: true

Fabricator(:user) do
  name 'Paul Campbell'
  email { "paul#{Fabricate.sequence(:email)}@rslw.com" }
  password 'monkeys'
  default_locale 'en-US'
  confirmed_at Time.zone.now
end

Fabricator(:admin_user, from: :user) do
  name 'Admin'
  email 'admin@safecast.org'
  password '111111'
  confirmed_at Time.zone.now
  default_locale 'en-US'
  moderator true
end
