class FixAddresses < ActiveRecord::Migration
  def self.up
    remove_column :addresses, :name
    add_column :addresses, :is_po_box, :boolean, :null => false, :default => false
  end

  def self.down
    add_column :addresses, :name, :string
    remove_column :addresses, :is_po_box
  end
end
