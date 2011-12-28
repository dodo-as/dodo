
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
    @ops = JournalOperation.where({:account_id => params[:id],:closed_operation_id => nil}).order('ledger_id, updated_at').all().to_a()
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
        if kid_match
          matched_by = "kid"
        elsif bill_match
          matched_by = "bill"
        else
          matched_by = nil
        end
        
        if (op.amount == -op2.amount) and (op.ledger == op2.ledger) and (kid_match or bill_match) then
          @matches << [op, op2,matched_by]
        end
      end
      
    end
  end



  def create

    ClosedOperation.transaction do 

      #when locked by matched operations using "lock all"
      if params['mops']

      puts "-------------------------------------"
      puts "Locked by matched operations"
      puts "-------------------------------------"

        params['mops'].each do
          |idx, ops|
          ops = ops.split(',').collect! {|n| n.to_i}
          cl = ClosedOperation.new
          cl.save
          ops.each do
            |op_id| 
            op = JournalOperation.find(op_id)
            op.closed_operation = cl 
            op.save 
          end
          add_tag(cl.id)
        end
      else
      puts "-------------------------------------"
      puts "Locked manually"
      puts "-------------------------------------"

      #when locked manually
        cl = ClosedOperation.new 
        cl.save
        if params['ops'].is_a?(String)
          params['ops'] = params['ops'].split(',').collect! {|n| n.to_i}
        end
        params['ops'].each do
          |op_id|
          puts op_id
          op = JournalOperation.find(op_id)
          op.closed_operation = cl 
          op.save 
        end
        add_tag(cl.id)
      end

      #        redirect_to("/payment_runs/#{params['pay_id']}/edit") 
      redirect_to :action => :edit, :id => params['pay_id']
    end 
  end

  def update
  end

  def destroy
  end

  private
  def add_tag(clid)
          #investigate if it is matched by kid or invoice
      jos = JournalOperation.where(:closed_operation_id => clid)
      count = jos.count
      kid = jos.first.journal.kid
      bill = jos.first.journal.bill_number

      count_same_kid = Journal.joins(:journal_operations).where(:journal_operations => {:closed_operation_id => clid}).where("kid is not null").where(:journals=> {:kid => kid}).count
      count_same_bill = Journal.joins(:journal_operations).where(:journal_operations => {:closed_operation_id => clid}).where("bill_number is not null").where(:journals=> {:bill_number => bill}).count

      if count == count_same_kid
          cop = ClosedOperation.find(clid)
          cop.matched_by = "k"
          cop.save
      elsif count == count_same_bill
          cop = ClosedOperation.find(clid)
          cop.matched_by = "b"
          cop.save
      end
  end
end
