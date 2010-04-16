class Entry < ActiveRecord::Base
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
    return nil if dec.blank?
    dec.split('.').inject(0) {|total,value| (total << 8) + value.to_i}
  end

  #
  # Accept an IP address as an integer and return it as a dot notation string
  # 
  def self.ip_as_dec(int)
    [24,16,8,0].collect {|o| (int >> o) & 255}.join '.'
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
