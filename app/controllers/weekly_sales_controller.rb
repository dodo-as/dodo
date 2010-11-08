class WeeklySalesController < ApplicationController
  # GET /weekly_sales
  # GET /weekly_sales.xml
  def index
    @weekly_sales = WeeklySale.with_permissions_to(:index).order('from_date desc').paginate({:page => params[:page]})

    @weekly_sale_setups = WeeklySaleSetup.with_permissions_to(:index).order("name")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weekly_sales }
    end
  end

  # GET /weekly_sales/1
  # GET /weekly_sales/1.xml
  def show
    @weekly_sale = WeeklySale.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weekly_sale }
    end
  end

  # GET /weekly_sales/new
  # GET /weekly_sales/new.xml
  def new
    weekly_sale = WeeklySale.create_weekly_sale(params[:weekly_sale_setup_id], @me.current_company.id)
    
      redirect_to :controller => "weekly_sales", :action => "edit", :id => weekly_sale.id    

  end

  # GET /weekly_sales/1/edit
  def edit
    @weekly_sale = WeeklySale.find(params[:id])
    list_periods
  end

  # POST /weekly_sales
  # POST /weekly_sales.xml
  def create
    @weekly_sale = WeeklySale.new(params[:weekly_sale])
    @weekly_sale.company_id = @me.current_company.id
    respond_to do |format|
      if @weekly_sale.save
        format.html { redirect_to(@weekly_sale, :notice => 'Weekly sale was successfully created.') }
        #list_weekly_sale_setups
        #list_periods
        format.xml  { render :xml => @weekly_sale, :status => :created, :location => @weekly_sale }
      else
        list_weekly_sale_setups
        list_periods
        format.html { render :action => "new" }        
        format.xml  { render :xml => @weekly_sale.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /weekly_sales/1
  # PUT /weekly_sales/1.xml
  def update
    @weekly_sale = WeeklySale.find(params[:id])
    respond_to do |format|
      if params[:weekly_sale_shifts].blank? ? @weekly_sale.update_attributes_without_childs(params[@weekly_sale]) : @weekly_sale.update_attributes_with_childs(params[:weekly_sale], params[:weekly_sale_shifts], params[:weekly_sale_shift_product_groups], params[:weekly_sale_shift_liquids], current_user)
        format.html { redirect_to(:action=>'show', :id=>@weekly_sale.id, :notice => 'Weekly sale was successfully updated.') }
        format.xml  { head :ok }
      else
        list_periods
        format.html { render :action => "edit" }
        format.xml  { render :xml => @weekly_sale.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_sales/1
  # DELETE /weekly_sales/1.xml
  def destroy
    @weekly_sale = WeeklySale.find(params[:id])
    @weekly_sale.destroy
    respond_to do |format|
      format.html { redirect_to(weekly_sales_url) }
      format.xml  { head :ok }
    end
  end

  def add_shift
    @weekly_sale = WeeklySale.find(params[:weekly_sale_id])
    @weekly_sale_shift = WeeklySaleShift.new(:id=>0)
    @counter = (Time.now.to_f.to_s.sub('.', '_') + '_' + rand(9999999).to_s).to_s
    render :update do |page| 
       page.insert_html :after, "row_weekly_sale_shift_#{params[:id]}", {:partial => 'shift', :locals=>{:unique_id=>(Time.now.to_f.to_s.sub('.', '_') + '_' + rand(9999999).to_s).to_s, :weekly_sale_setup_id=>@weekly_sale.weekly_sale_setup.id.to_s, :shift_id=>nil, :date_shift=>params[:date]}}
    end 
  end

  def destroy_shift
    render :update do |page|
      page["row_weekly_sale_shift_#{params[:id]}"].remove ##render(:partial=>'shift', :locals=>{:shift_id=>nil})      
    end
  end

  private 

  def list_periods
   @periods = Period.with_permissions_to(:index).all(:order => "year, nr")
  end

  def list_weekly_sale_setups
   @weekly_sale_setups = WeeklySaleSetup.with_permissions_to(:read).all(:order => "name")
  end

end
