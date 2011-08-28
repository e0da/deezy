# http://brandontilley.com/2011/01/29/rvm-unicorn-and-upstart.html
#if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
#  begin
#    rvm_path     = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
#    rvm_lib_path = File.join(rvm_path, 'lib')
#    $LOAD_PATH.unshift rvm_lib_path
#    require 'rvm'
#    RVM.use_from_path! File.dirname(File.dirname(__FILE__))
#  rescue LoadError
#    raise "The RVM Ruby library is not available."
#  end
#end

worker_processes 2

user "deezy", "nogroup"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
#working_directory "/path/to/app/current" # available in 0.94.0+

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/.sock", :backlog => 64
#listen 8080, :tcp_nopush => true

timeout 30

# feel free to point this anywhere accessible on the filesystem
pid "/opt/deezy/tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, some applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "/opt/deezy/log/unicorn.stderr.log"
stdout_path "/opt/deezy/log/unicorn.stdout.log"

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
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

