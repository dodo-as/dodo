class RemoveNetBankAndAutoPayment < ActiveRecord::Migration
  def self.up
    remove_column :ledgers, :net_bank
    remove_column :ledgers, :auto_payment
  end

  def self.down
    add_column :ledgers, :auto_payment  , :boolean
    add_column :ledgers, :net_bank      , :boolean
  end
end
