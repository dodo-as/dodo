class AddUnitIdToJournalOperationsStep2 < ActiveRecord::Migration
  def self.up
    remove_column :journals, :unit_id
  end

  def self.down
    add_column :journals, :unit_id, :integer
  end
end
