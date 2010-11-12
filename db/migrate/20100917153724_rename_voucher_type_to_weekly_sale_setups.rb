class RenameVoucherTypeToWeeklySaleSetups < ActiveRecord::Migration
  def self.up
    rename_column :weekly_sale_setups, :voucher_type, :journal_type
  end

  def self.down
    rename_column :weekly_sale_setups, :journal_type, :voucher_type
  end
end
