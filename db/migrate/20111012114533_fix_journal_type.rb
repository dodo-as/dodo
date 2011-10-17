class FixJournalType < ActiveRecord::Migration
  def self.up
    create_table :journal_type_counters do |t|
      t.references :journal_type, :null => false
      t.references :company, :null => false
      t.integer :counter, :null => false, :default => 1
      t.boolean :adjust_outside_of_sequence, :null => false, :default => false
    end
    
    add_column :journal_types, :abbreviation, :string, :null => false
    
  end
  
  def self.down
    drop_table :journal_type_counters
    remove_column :journal_types, :abbreviation
  end
end
