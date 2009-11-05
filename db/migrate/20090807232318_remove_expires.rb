class RemoveExpires < ActiveRecord::Migration
  def self.up
    remove_column :entries, :expires
  end

  def self.down
    add_column :entries, :expires, :datetime
  end
end
