class AddParallelPurchaseToSaleVatAccounts < ActiveRecord::Migration
  def self.up
    add_column :vat_accounts, :is_sales_account, :boolean, :null => false
  end

  def self.down
    remove_column :vat_accounts, :is_sales_account
  end
end
