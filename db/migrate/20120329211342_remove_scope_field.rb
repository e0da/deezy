class RemoveScopeField < ActiveRecord::Migration
  def self.up
    remove_column :hosts, :scope
  end

  def self.down
    add_column :hosts, :scope, :string
  end
end
