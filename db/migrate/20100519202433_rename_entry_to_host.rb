class RenameEntryToHost < ActiveRecord::Migration
  def self.up
    rename_table :entries, :hosts
  end

  def self.down
    rename_table :hosts, :entries
  end
end
