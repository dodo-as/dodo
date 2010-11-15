class AddAmountColumn < ActiveRecord::Migration
  def self.up
    add_column :accounts, :amount, :decimal, :precision => 20, :scale => 2
    add_column :journals, :unit_id, :integer  
    remove_column :journal_operations, :unit_id
    add_column :journals, :kid, :string
    add_column :journals, :bill_number, :string
    add_column :journals, :description, :string
  end

  def self.down
    remove_column :accounts, :amount 
    remove_column :journals, :unit_id
    add_column :journal_operations, :unit_id, :integer
    remove_column :journals, :kid
    remove_column :journals, :bill_number
    remove_column :journals, :description
  end
end
