class CountiesLedgersCreateRelationship < ActiveRecord::Migration
  def self.up
    add_column :county_tax_zones, :ledger_id, :integer
  end

  def self.down
    remove_column :county_tax_zones, :ledger_id, :integer
  end
end
