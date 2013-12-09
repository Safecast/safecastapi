env :PATH, ENV['PATH']

every 240.minutes, :roles => [:app] do
  command "/var/deploy/api.safecast.org/web_head/current/script/dump_measurements_ios"
  command "/var/deploy/api.safecast.org/web_head/current/script/dump_measurements"
end

# every 45.minutes, :roles => [:app] do
#   command "/var/deploy/api.safecast.org/web_head/current/script/dump_measurements"
# end

# every 4.hours, :roles => [:app] do
#  command "/var/deploy/api.safecast.org/web_head/current/script/dump_measurements_ios"
# end
