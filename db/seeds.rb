# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

moderator = User.new(name: 'Safecast Moderator', email: 'safecast.moderator.1@mailinator.com', password: 'abc123', password_confirmation: 'abc123')
moderator.confirmed_at = Time.now
moderator.moderator = true
moderator.save!

uploader = User.new(name: 'Safecast Uploader', email: 'safecast.uploader.1@mailinator.com', password: 'abc123', password_confirmation: 'abc123')
uploader.confirmed_at = Time.now
uploader.save!
