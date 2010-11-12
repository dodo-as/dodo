class CreateJournalTypeRelationToJournals < ActiveRecord::Migration
  def self.up
    remove_column :journals, :journal_type
    add_column :journals, :journal_type_id, :integer
  end

  def self.down
    add_column :journals, :journal_type, :string, :limit=>3
    remove_column :journals, :journal_type_id
  end
end
