require 'net/ldap'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password
  before_filter :authenticate

  protected

  def authenticate
    is_mundo_or_local? or can_bind_as_help?
  end

  def can_bind_as_help?
    authenticate_or_request_with_http_basic do |username, password|
      # only help can authenticate, and you still have to type it
      if username == 'help'
        ldap = Net::LDAP.new
        ldap.host = 'directory.education.ucsb.edu'
        ldap.auth 'uid=help,ou=people,o=education.ucsb.edu', password
        ldap.bind 
      end
    end
  end

  def is_mundo_or_local?
    request.remote_ip == '187.0.0.1' or request.remote_ip == '128.111.207.250'
  end

end
