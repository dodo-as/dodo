class AddFieldIsVisibleToTaxZoneTaxes < ActiveRecord::Migration
  def self.up
     add_column :tax_zone_taxes, :is_visible, :boolean, :default=>true
  end

  def self.down
     remove_column :tax_zone_taxes, :is_visible
  end
end
