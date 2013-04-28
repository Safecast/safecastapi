namespace :db do
  desc "Prevent dangerous things in production"
  task :protect do
    if %w[production staging].include? Rails.env
      fail "Refusing to run in non-development environment"
    end
  end

  desc "Create dummy user"
  task :bootstrap => [:protect, :environment] do
    u = User.create!(
      email: 'admin@safecast.org',
      name: 'Fake Admin',
      password: '111111',
      password_confirmation: '111111'
    )
    puts "Created user #{u.email} with password #{u.password}"
  end
end
