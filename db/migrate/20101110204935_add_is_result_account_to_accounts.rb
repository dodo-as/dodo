class AddIsResultAccountToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :is_result_account, :boolean, :default=>false
    execute "update accounts set is_result_account = true where number >= 3000"
    execute "update accounts set is_result_account = false where number < 3000"
  end

  def self.down
    remove_column :accounts, :is_result_account
  end
end
