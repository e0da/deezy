worker_processes 2

user "deezy", "nogroup"
listen "/tmp/.sock", :backlog => 64

timeout 30

pid "/opt/deezy/tmp/pids/unicorn.pid"

stderr_path "/opt/deezy/log/unicorn.stderr.log"
stdout_path "/opt/deezy/log/unicorn.stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

