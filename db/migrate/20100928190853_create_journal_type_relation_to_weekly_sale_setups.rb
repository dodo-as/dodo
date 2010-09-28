class CreateJournalTypeRelationToWeeklySaleSetups < ActiveRecord::Migration
  def self.up
    remove_column :weekly_sale_setups, :journal_type
    add_column :weekly_sale_setups, :journal_type_id, :integer
  end

  def self.down
    add_column :weekly_sale_setups, :journal_type, :string, :limit=>3
    remove_column :weekly_sale_setups, :journal_type_id
  end
end
