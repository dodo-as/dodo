class RemovePaycheckId < ActiveRecord::Migration
  def self.up
     remove_column :county_tax_zones, :paycheck_id
  end

  def self.down
  end
end
