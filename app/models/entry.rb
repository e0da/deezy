class Entry < ActiveRecord::Base
  validates_uniqueness_of :hostname
  validates_format_of :mac, :with => /[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}/
  validates_format_of :ip, :with => /(128.111.(20[67]|186).\d{1,3}|)/
  validates_format_of :itgid, :with => /\d{2}[48]00\d{4}/
  validates_format_of :hostname, :with => /[a-z0-9]([a-z0-9-][a-z0-9]{0,61}[a-z0-9]|[a-z0-9])/
  validates_format_of :uid, :with => /[a-z0-9]([a-z0-9-][a-z0-9]{0,61}[a-z0-9]|[a-z0-9])/
  validates_format_of :room, :with => /\d{4}[A-Z]?/

  named_scope :any_like, lambda { |*args|
    { :conditions => ['mac like ? or ip like ? or itgid like ? or room like ? or hostname like ? or uid like ? or notes like ?', '%'+args.first+'%', '%'+args.first+'%', '%'+args.first+'%', '%'+args.first+'%', '%'+args.first+'%', '%'+args.first+'%', '%'+args.first+'%'] }
  }

  def to_param
    hostname
  end

end
