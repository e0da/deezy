# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

def start(env='development')
  `passenger start --daemon --environment #{env}`
end

def stop
  `passenger stop`
end

desc 'Start server in development mode'
task :start do
  start
end

desc 'Stop server'
task :stop do
  stop
end

desc 'Restart server in development mode'
task :restart => [:stop, :start]

namespace :production do

  desc 'Start server in production mode'
  task :start do
    start 'production'
  end

  desc 'Stop server'
  task :stop do
    stop
  end

  desc 'Restart server in production mode'
  task :restart => [:stop, :start]
end
