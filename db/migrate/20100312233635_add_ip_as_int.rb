class AddIpAsInt < ActiveRecord::Migration
  def self.up
    add_column :entries, :ip_int, :integer
    Entry.reset_column_information
    say_with_time 'Calculating IPs as integers' do
      entries = Entry.find_all
      entries.each do |e|
        ip = e.ip.split('.').inject(0) {|t,v| (t << 8) + v.to_i}
        e.update_attribute(:ip_int, ip)
      end
    end
  end

  def self.down
    remove_column :entries, :ip_int
  end
end
