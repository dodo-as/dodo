class CountyTaxZone < ActiveRecord::Base
  belongs_to :county
  belongs_to :tax_zone 
  belongs_to :paycheck
  belongs_to :ledger
end
