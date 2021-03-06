class BillsController < ApplicationController
  before_filter :load_bill, :only => [:show, :edit, :update, :destroy]
  before_filter :right_company, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all

  def load_bill
    @bill = Bill.find(params[:id])
  end

  def right_company
    if @me.companies.include? @bill.company
      @me.current_company = @bill.company
      @me.save!
      return true
    end

    flash[:notice]='You can only manage your own bills. Go away.'
    redirect_to :action => "index"
    return false 
  end

  # GET /bills
  # GET /bills.xml
  def index
    @bills = Bill.order(:updated_at).find(@me.current_company.bills)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bills }
    end
  end
  
  # GET /bills/1
  # GET /bills/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bill }
    end
  end

  def get_all_orders
    @orders_all = Order.where(:company_id => current_user.current_company.id).joins(:company).order("companies.name, orders.created_at")
  end

  # GET /bills/new
  # GET /bills/new.xml
  def new
    get_all_orders
    @bill = Bill.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bill }
    end
  end

  # GET /bills/1/edit
  def edit
    get_all_orders
  end

  def post_to_model(post)
    bill_model = Hash.new
    post = post.clone()

    ['delivery_date', 
     'billing_date',
     'period_id',
     'due_date'].each do |name|
      bill_model[name] = post.delete name
    end

    if post.include? 'id'
      bill_model['id'] = post.delete 'id'
    end

    bill_model = Bill.create_or_update(bill_model)
    bill_model.bill_orders.clear

    post.values.each do |bill_order_post|
      bill_order_model = Hash.new
      bill_order_model['order_id'] = bill_order_post['order_id']
      if bill_order_post.include? 'id'
        bill_order_model['id'] = bill_order_post['id']
      end
      bill_order_post = bill_order_post['details'].clone()

      bill_order_model = BillOrder.create_or_update(bill_order_model)
      bill_model.bill_orders.push bill_order_model
      bill_order_model.bill_items.clear

      bill_order_post.values.each do |item|
	item = item.clone()
        item.delete 'discount'
	item = BillItem.create_or_update(item)
        bill_order_model.bill_items.push item
      end
    end

    bill_model
  end


  # POST /bills
  # POST /bills.xml
  def create
    @bill = post_to_model params[:bill]
    @bill.company_id = @me.current_company.id
    respond_to do |format|
      saved = true
      begin
        Bill.transaction do
          @bill.post_invoice! if params[:close_invoice].to_i == 1
          @bill.save!
        end # commit
#      rescue Exception
#        saved = false
      end
      if saved
        flash[:notice] = 'Bill was successfully created.'
        format.html { redirect_to(@bill) }
        format.xml  { render :xml => @bill, :status => :created, :location => @bill }
      else
        flash.now[:notice] = 'Error saving bill.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @bill.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bills/1
  # PUT /bills/1.xml
  def update
    raise "bill is closed" if !@bill.editable?
    params[:bill]['id'] = params[:id]
    @bill = post_to_model params[:bill]

    respond_to do |format|
      saved = true
      begin
        Bill.transaction do
          @bill.post_invoice! if params[:close_invoice].to_i == 1
          @bill.save!
        end # commit
      rescue Exception
        saved = false
      end
      if saved
        flash[:notice] = 'Bill was successfully updated.'
        format.html { redirect_to(@bill) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bill.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.xml
  def destroy
    raise "bill closed" if !@bill.editable?
    @bill.destroy

    respond_to do |format|
      format.html { redirect_to(bills_url) }
      format.xml  { head :ok }
    end
  end
end
