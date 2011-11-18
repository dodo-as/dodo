class RemoveFieldLedgersIdFromCountyTaxZones < ActiveRecord::Migration
  def self.up
    remove_column :county_tax_zones, :ledger_id
  end

  def self.down
  end
end
