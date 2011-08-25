worker_processes 2
working_directory '/opt/deezy/'

preload_app true

timeout 30

#listen '127.0.0.1:80'

pid '/opt/deezy/tmp/pids/unicorn.pid'

stderr_path '/var/deezy/log/unicorn.stderr.log'
stdout_path '/var/deezy/log/unicorn.stdout.log'

before_fork do |server, worker|
  defined? ActiveRecord::Base and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined? ActiveRecord::Base and ActiveRecord::Base.establish_connection
end

