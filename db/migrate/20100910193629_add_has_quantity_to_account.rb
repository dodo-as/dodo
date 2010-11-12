class AddHasQuantityToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :has_quantity, :boolean, :default=>false
  end

  def self.down
    remove_column :accounts, :has_quantity
  end
end
