class TaxZone < ActiveRecord::Base
  has_many :tax_zone_taxes
  has_many :county_tax_zones
  accepts_nested_attributes_for :county_tax_zones, :allow_destroy => false
  accepts_nested_attributes_for :tax_zone_taxes, :allow_destroy => false
end
