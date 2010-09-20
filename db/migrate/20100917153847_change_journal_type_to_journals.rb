class ChangeJournalTypeToJournals < ActiveRecord::Migration
  def self.up
    change_column :journals, :journal_type, :string, :limit=>3
  end

  def self.down
    change_column :journals, :journal_type, :integer    
  end
end
