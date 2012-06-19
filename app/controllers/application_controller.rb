require 'net/ldap'
require 'yaml'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password
  before_filter :authenticate

  protected

  def conf
    @@conf ||= YAML.load_file "#{Rails.root}/config/deezy.yml"
  end

  def authenticate
    is_exempt? or can_bind_as_help?
  end

  def can_bind_as_help?

    # use authentication if it's configured
    if conf['auth']
      authenticate_or_request_with_http_basic do |username, password|

        # only help can authenticate, and you still have to type it
        ldconf = conf['auth']['ldap']
        if username == ldconf['username']
          ldap = Net::LDAP.new
          ldap.host = ldconf['host']
          ldap.port = ldconf['port'] if ldconf['port']
          ldap.auth(
            ldconf['bind_dn'] % username,
            password
          )
          ldap.bind 
        end
      end
    end
  end

  def is_exempt?
    if conf['auth'] && conf['auth']['exempt_ips']
      conf['auth']['exempt_ips'].include? request.remote_ip 
    else
      true
    end
  end
end
