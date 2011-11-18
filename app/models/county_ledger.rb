class CountyLedger < ActiveRecord::Base

     belongs_to :county
     belongs_to :ledger

     #def initialize(ledger_id, county_id, from)
        #@ledger_id = ledger_id
        #@county_id = county_id
        #@from = from
     #end

     
end
