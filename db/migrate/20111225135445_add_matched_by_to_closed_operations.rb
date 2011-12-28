class AddMatchedByToClosedOperations < ActiveRecord::Migration

  def self.up
    add_column :closed_operations, :matched_by, :text, :default => nil
  end

  def self.down
     remove_column :closed_operations, :matched_by
  end
  
end
