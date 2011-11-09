class LedgersAddCounty < ActiveRecord::Migration
  def self.up
    add_column :ledgers, :county_id, :integer 
  end

  def self.down
    remove_column :ledgers, :county_id 
  end
end
