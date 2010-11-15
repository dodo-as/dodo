class RenameAmount < ActiveRecord::Migration
  def self.up
    add_column :journal_operations, :amount_other, :decimal, :precision => 20, :scale => 2 
  end

  def self.down
    remove_column :journal_operations, :amount_other
  end
end
