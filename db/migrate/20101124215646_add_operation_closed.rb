class AddOperationClosed < ActiveRecord::Migration
  def self.up
    add_column :journal_operations, :closed_operation_id, :integer  
  end

  def self.down
    remove_column :journal_operations, :closed_operation_id
  end
end
