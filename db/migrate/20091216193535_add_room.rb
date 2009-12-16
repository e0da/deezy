class AddRoom < ActiveRecord::Migration
  def self.up
    add_column :entries, :room, :string
  end

  def self.down
    remove_column :entries, :room
  end
end
