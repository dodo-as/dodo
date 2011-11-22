class CountyLedgersController < ApplicationController
    def new
        @county_ledger = CountyLedger.new
        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml => @county_ledger }
        end
    end

    def create
        @county_ledger = CountyLedger.new(params[:county_ledger])
        respond_to do |format|
          
          if @county_ledger.save!
              format.html { redirect_to(ledger_path(@county_ledger.ledger)) }
              format.xml  { render :xml => @county_ledger} #, :status => :created, :location => @journal }
          else   
              format.html { render :action => "new" }
              format.xml  { render :xml => @county_ledger.errors, :status => :unprocessable_entity }
          end
        
        end
    end


end
