class RemoveDuplicatePersonalNumberFromLedgers < ActiveRecord::Migration
  def self.up
    remove_column :ledgers, :personal_number
  end

  def self.down
    add_column :ledgers, :personal_number, :string
  end
end
