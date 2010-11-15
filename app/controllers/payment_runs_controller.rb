
class PaymentRunsController < ApplicationController

  def index
#    @accounts = Account.with_permissions_to(:index).where({:has_ledger => true}).all(:order => "number")
    @accounts = Account.with_permissions_to(:index).where({:has_ledger => true}).all()
    
    respond_to do |format|
      format.html # index.html.erb
#      format.xml  { render :xml => @journals }
    end
  end

  def show
  end
  
  def new
  end

  def edit
    @ops = JournalOperation.where({:account_id => params[:id]}).all().to_a()
    @matches = []
    @ops.each_with_index do
      |op, idx| 
      @ops[idx+1,@ops.size()].each do
        |op2|
        if op.amount == op2.amount and op.ledger == op2.ledger then
          op2.amount = -op2.amount
          @matches << [op, op2]
          
        end
      end
      

      
    end
  end

  def create
  end

  def update
  end

  def destroy
  end

end
