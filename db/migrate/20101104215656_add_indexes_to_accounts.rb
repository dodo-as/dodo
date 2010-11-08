class AddIndexesToAccounts < ActiveRecord::Migration
  def self.up
    add_index :accounts, :number
    add_index :accounts, :company_id
    add_index :accounts, :vat_account_id
    add_index :accounts, :activatable_id
  end

  def self.down
    remove_index :accounts, :number
    remove_index :accounts, :company_id
    remove_index :accounts, :vat_account_id
    remove_index :accounts, :activatable_id
  end
end
