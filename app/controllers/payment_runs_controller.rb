
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
    @ops = JournalOperation.where({:account_id => params[:id],:closed_operation_id => nil}).order('ledger_id').all().to_a()
    @matches = []
    @pay_id = params[:id]
    @ops.each_with_index do
      |op, idx| 
      #print "Search #{op}\n"
      j = op.journal

      @ops[idx+1,@ops.size()].each do
        |op2|

        #print "#{op.amount} #{op2.amount} #{op.ledger.name} #{op2.ledger.name}\n"
        j2 = op2.journal
        
        kid_match = ((j.kid != nil and j2.kid !=nil) and (j.kid == j2.kid))
        bill_match = ((j.bill_number != nil and j2.bill_number != nil) and (j.bill_number == j2.bill_number))
        
        if (op.amount == -op2.amount) and (op.ledger == op2.ledger) and (kid_match or bill_match) then
          @matches << [op, op2]
        end
      end
      
    end
  end



  def create

    ClosedOperation.transaction do 
      print "WEEE!!!! #{params['ops']}\n\n" 
      cl = ClosedOperation.new 
      cl.save 
      params['ops'].each do
        |op_id| 
        print "Close #{op_id}\n\n"
        op = JournalOperation.where({:id => op_id}).first
        op.closed_operation = cl 
        op.save 
      end 
      #        redirect_to("/payment_runs/#{params['pay_id']}/edit") 
      redirect_to :action => :edit, :id => params['pay_id']
    end 
  end

  def update
  end

  def destroy
  end

end
