require 'ipaddr'

class Host < ActiveRecord::Base
  validates_uniqueness_of :hostname
  validates_format_of :mac, :with => /[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}/
  validates_format_of :ip, :with => /(128.111.(20[67]|186).\d{1,3}|)/
  validates_format_of :itgid, :with => /\d{2}[48]00\d{4}/
  validates_format_of :hostname, :with => /[a-z0-9]([a-z0-9-][a-z0-9]{0,61}[a-z0-9]|[a-z0-9])/
  validates_format_of :uid, :with => /[a-z0-9]([a-z0-9-][a-z0-9]{0,61}[a-z0-9]|[a-z0-9])/
  validates_format_of :room, :with => /\d{4}[A-Z]?/

  before_save :clean_html

  #
  # Accept an IP address as a dot notation string and return it as an integer
  #
  def self.ip_as_int(dec)
    # FIXME can I get rid of this return nil?
    return nil if dec.blank?
    IPAddr.new(dec).to_i
  end

  #
  # Accept an IP address as an integer and return it as a dot notation string
  # 
  def self.ip_as_dec(int)
    IPAddr.new(int, Socket::AF_INET).to_s
  end

  def self.used_ips
    used_ips = []
    Host.find_all_by_enabled(true).collect do |host|
      used_ips << IPAddr.new(host.ip) unless host.ip.blank?
    end
    used_ips
  end

  def self.last_updated
    Time.gm(*find(:first, :order => 'updated_at DESC', :limit => 1).updated_at)
  end

  #
  # Clean HTML to prevent XSS and ugliness
  #
  def clean_html
    [mac, ip, itgid, room, hostname, uid, notes].each do |e|
      e.gsub! /&/, '&amp;'
      e.gsub! /</, '&lt;'
      e.gsub! />/, '&gt;'
    end
  end
end
