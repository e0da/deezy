RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'PDT'
  config.action_controller.relative_url_root = '/deezy'
end
