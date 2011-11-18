class RemoveFieldCountyLedgers < ActiveRecord::Migration
  def self.up
     remove_column :ledgers, :county_id
  end

  def self.down
  end
end
