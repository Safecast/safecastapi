worker_processes 4

working_directory ENV['RAILS_STACK_PATH'].to_s

listen '/tmp/web_server.sock', backlog: 64

timeout 120

pid '/tmp/web_server.pid'

stderr_path "#{ENV['RAILS_STACK_PATH']}/log/unicorn.stderr.log"
stdout_path "#{ENV['RAILS_STACK_PATH']}/log/unicorn.stdout.log"

preload_app true
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

check_client_connection false

before_fork do |server, _worker|
  old_pid = '/tmp/web_server.pid.oldbin'
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH # rubocop:disable Lint/HandleExceptions
      # someone else did our job for us
    end
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |_server, _worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
