class AddIpAsInt < ActiveRecord::Migration
  def self.up
    add_column :entries, :ip_int, 'integer unsigned'
    Entry.reset_column_information
    Entry.all.each do |e|
      unless e.ip.blank? 
        e.update_attribute :ip_int, Entry::ip_as_int(e.ip)
      end
    end
  end

  def self.down
    remove_column :entries, :ip_int
  end
end
