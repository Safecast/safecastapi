# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

namespace :db do
  desc 'Prevent dangerous things in production'
  task :protect do
    if %w(production staging).include? Rails.env
      raise 'Refusing to run in non-development environment'
    end
  end

  desc 'Create dummy users'
  task bootstrap: %i(protect environment) do
    u = User.create!(
      email: 'admin@safecast.org',
      name: 'Fake Admin',
      password: '111111',
      password_confirmation: '111111'
    )
    u.moderator = true
    u.confirmed_at = Time.now
    u.save
    puts "Created user #{u.email} with password #{u.password}"
    attrs = {
      name: 'Fake User',
      password: '111111',
      password_confirmation: '111111',
      moderator: false,
      confirmed_at: Time.now
    }
    %w(user1@safecast.org user2@safecast.org).each do |email|
      u = User.create!(attrs.merge(email: email))
      puts "Created user #{email} with password #{u.password}"
    end
  end
end
# rubocop:enable Metrics/BlockLength
