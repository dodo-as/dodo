class AddIndexesToJournals < ActiveRecord::Migration
  def self.up
    add_index :journals, :bill_id
    add_index :journals, :period_id
    add_index :journals, :journal_type_id
  end

  def self.down
    remove_index :journals, :bill_id
    remove_index :journals, :period_id
    remove_index :journals, :journal_type_id
  end
end
