class AddCodeAndActivenessToVatAccounts < ActiveRecord::Migration
  def self.up
    add_column :vat_accounts, :code, :integer
    add_column :vat_accounts, :active, :boolean
  end

  def self.down
    remove_column :vat_accounts, :code
    remove_column :vat_accounts, :active
  end
end
