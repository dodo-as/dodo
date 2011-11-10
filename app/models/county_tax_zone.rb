class CountyTaxZone < ActiveRecord::Base
  belongs_to :county
  belongs_to :tax_zone 
end
