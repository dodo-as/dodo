class CountyTaxZonesAddIsVisibleField < ActiveRecord::Migration
  def self.up
     add_column :county_tax_zones, :is_visible, :boolean, :default=>true
  end

  def self.down
     remove_column :county_tax_zones, :is_visible
  end
end
