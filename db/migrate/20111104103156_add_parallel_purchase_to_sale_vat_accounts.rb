class AddParallelPurchaseToSaleVatAccounts < ActiveRecord::Migration
  def self.up

    # store purchase/sale in the account itself, since the linked vat account is both
    add_column :accounts, :is_sales_account, :boolean, :null => :false, :default => :true

    # split up vat account link
    rename_column :vat_accounts, :target_account_id, :target_sales_account_id
    add_column :vat_accounts, :target_purchase_account_id, :integer

    # and code
    rename_column :vat_accounts, :code, :sales_code
    add_column :vat_accounts, :purchase_code, :integer

  end

  def self.down

    remove_column :vat_accounts, :purchase_code
    rename_column :vat_accounts, :sales_code, :code
    # and code

    remove_column :vat_accounts, :target_purchase_account_id
    rename_column :vat_accounts, :target_sales_account_id, :target_account_id
    # split up vat account link

    remove_column :accounts, :is_sales_account
    # store purchase/sale in the account itself, since the linked vat account is both

  end
end
