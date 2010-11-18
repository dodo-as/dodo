class AddIndexesToJournalOperations < ActiveRecord::Migration
  def self.up
    add_index :journal_operations, :journal_id
    add_index :journal_operations, :account_id
    add_index :journal_operations, :vat_account_id
    add_index :journal_operations, :project_id
    add_index :journal_operations, :ledger_id
  end

  def self.down
    remove_index :journal_operations, :journal_id
    remove_index :journal_operations, :account_id
    remove_index :journal_operations, :vat_account_id
    remove_index :journal_operations, :project_id
    remove_index :journal_operations, :ledger_id
  end
end
