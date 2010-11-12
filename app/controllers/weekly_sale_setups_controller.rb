class WeeklySaleSetupsController < ApplicationController
  # GET /weekly_sale_setups
  # GET /weekly_sale_setups.xml
  def index
    @weekly_sale_setups = WeeklySaleSetup.with_permissions_to(:index).all(:order => "name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weekly_sale_setups }
    end
  end

  # GET /weekly_sale_setups/1
  # GET /weekly_sale_setups/1.xml
  def show
    @weekly_sale_setup = WeeklySaleSetup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weekly_sale_setup }
    end
  end

  # GET /weekly_sale_setups/new
  # GET /weekly_sale_setups/new.xml
  def new
    @weekly_sale_setup = WeeklySaleSetup.new
    list_units
    list_accounts
    list_projects
    list_journal_types
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @weekly_sale_setup }
    end
  end

  # GET /weekly_sale_setups/1/edit
  def edit    
    @weekly_sale_setup = WeeklySaleSetup.find(params[:id])
    list_units
    list_accounts
    list_projects
    list_journal_types
  end

  # POST /weekly_sale_setups
  # POST /weekly_sale_setups.xml
  def create
    @weekly_sale_setup = WeeklySaleSetup.new(params[:weekly_sale_setup])
    @weekly_sale_setup.company_id = @me.current_company.id
    respond_to do |format|
      if @weekly_sale_setup.save && @weekly_sale_setup.update_attributes_with_childs(params[:weekly_sale_setup], params[:weekly_sale_setup_product_groups], params[:weekly_sale_setup_liquids])
        format.html { redirect_to(@weekly_sale_setup, :notice => 'Weekly sale setup was successfully created.') }
        format.xml  { render :xml => @weekly_sale_setup, :status => :created, :location => @weekly_sale_setup }
      else
        list_units
        list_accounts
        list_journal_types
        format.html { render :action => "new" }
        format.xml  { render :xml => @weekly_sale_setup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /weekly_sale_setups/1
  # PUT /weekly_sale_setups/1.xml
  def update
    @weekly_sale_setup = WeeklySaleSetup.find(params[:id])
    respond_to do |format|
      begin
        @weekly_sale_setup.update_attributes_with_childs(params[:weekly_sale_setup], params[:weekly_sale_setup_product_groups], params[:weekly_sale_setup_liquids])
        format.html { redirect_to(:action=>'show', :id=>@weekly_sale_setup.id, :notice => 'Weekly sale setup was successfully updated.') }
        format.xml  { head :ok }
      rescue Exception => e
        list_units
        list_accounts
        list_projects
        list_journal_types
        flash[:error] = e.to_s
        format.html { render :action => "edit" }
        format.xml  { render :xml => @weekly_sale_setup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_sale_setups/1
  # DELETE /weekly_sale_setups/1.xml
  def destroy
    @weekly_sale_setup = WeeklySaleSetup.find(params[:id])
    @weekly_sale_setup.destroy

    respond_to do |format|
      format.html { redirect_to(weekly_sales_url) }
      format.xml  { head :ok }
    end
  end

  def add_product_group
    list_accounts
    list_projects
    @weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.new(:id=>0)
    @counter = (Time.now.to_f.to_s.sub('.', '_') + '_' + rand(9999999).to_s).to_s
    render :update do |page| 
       page[:product_groups].show
       page.insert_html :before, 'rows_weekly_sale_setup_product_groups', {:partial => 'product_group', :locals=>{:unique_id=>(Time.now.to_f.to_s.sub('.', '_') + '_' + rand(9999999).to_s).to_s,  :product_group_id=>nil}}
    end 
  end

  def destroy_product_group
    render :update do |page|
      page["row_weekly_sale_setup_product_group_#{params[:id]}"].remove ##render(:partial=>'shift', :locals=>{:shift_id=>nil})      
    end
  end

  def add_liquid
    list_accounts
    #@weekly_sale_setup = WeeklySaleSetup.find(params[:with])
    @weekly_sale_setup_liquid = WeeklySaleSetupLiquid.new(:id=>0)
    @counter = (Time.now.to_f.to_s.sub('.', '_') + '_' + rand(9999999).to_s).to_s
    render :update do |page| 
       page[:liquids].show
       page.insert_html :before, 'rows_weekly_sale_setup_liquids', {:partial => 'liquid', :locals=>{:unique_id=>(Time.now.to_f.to_s.sub('.', '_') + '_' + rand(9999999).to_s).to_s,  :liquid_id=>nil}}
    end 
  end

  def destroy_liquid
    render :update do |page|
      page["row_weekly_sale_setup_liquid_#{params[:id]}"].remove ##render(:partial=>'shift', :locals=>{:shift_id=>nil})      
    end
  end

  private 

  def list_projects     
    @projects = Project.with_permissions_to(:read).all(:order => "name")
  end

  def list_units     
    @units = Unit.with_permissions_to(:read).all(:order => "name")
  end

  def list_accounts
   @accounts = Account.with_permissions_to(:read).all(:order => "number")
  end

  def list_journal_types
   @journal_types = JournalType.with_permissions_to(:read).all(:order => "name")
  end
end
