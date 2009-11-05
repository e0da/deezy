class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.string :scope
      t.string :mac
      t.string :ip
      t.string :itgid
      t.string :hostname
      t.string :uid
      t.datetime :expires
      t.boolean :enabled
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
