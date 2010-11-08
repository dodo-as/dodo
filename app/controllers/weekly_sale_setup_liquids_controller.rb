class WeeklySaleSetupLiquidsController < ApplicationController
  # GET /weekly_sale_setup_liquids
  # GET /weekly_sale_setup_liquids.xml
  def index
    @weekly_sale_setup_liquids = WeeklySaleSetupLiquid.with_permissions_to(:index).all(:order => "name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weekly_sale_setup_liquids }
    end
  end

  # GET /weekly_sale_setup_liquids/1
  # GET /weekly_sale_setup_liquids/1.xml
  def show
    @weekly_sale_setup_liquid = WeeklySaleSetupLiquid.find(params[:id])   

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weekly_sale_setup_liquid }
    end
  end

  # GET /weekly_sale_setup_liquids/new
  # GET /weekly_sale_setup_liquids/new.xml
  def new
    @weekly_sale_setup_liquid = WeeklySaleSetupLiquid.new
    list_accounts
    list_weekly_sale_setups

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @weekly_sale_setup_liquid }
    end
  end

  # GET /weekly_sale_setup_liquids/1/edit
  def edit
    @weekly_sale_setup_liquid = WeeklySaleSetupLiquid.find(params[:id])
    list_accounts
    list_weekly_sale_setups
  end

  # POST /weekly_sale_setup_liquids
  # POST /weekly_sale_setup_liquids.xml
  def create
    @weekly_sale_setup_liquid = WeeklySaleSetupLiquid.new(params[:weekly_sale_setup_liquid])
    @weekly_sale_setup_liquid.company_id = @me.current_company.id
    respond_to do |format|
      if @weekly_sale_setup_liquid.save
        format.html { redirect_to(@weekly_sale_setup_liquid, :notice => 'Weekly sale setup liquid was successfully created.') }
        format.xml  { render :xml => @weekly_sale_setup_liquid, :status => :created, :location => @weekly_sale_setup_liquid }
      else
        list_accounts
        list_weekly_sale_setups
        format.html { render :action => "new" }
        format.xml  { render :xml => @weekly_sale_setup_liquid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /weekly_sale_setup_liquids/1
  # PUT /weekly_sale_setup_liquids/1.xml
  def update
    @weekly_sale_setup_liquid = WeeklySaleSetupLiquid.find(params[:id])

    respond_to do |format|
      if @weekly_sale_setup_liquid.update_attributes(params[:weekly_sale_setup_liquid])
        format.html { redirect_to(@weekly_sale_setup_liquid, :notice => 'Weekly sale setup liquid was successfully updated.') }
        format.xml  { head :ok }
      else
        list_accounts
        list_weekly_sale_setups
        list_weekly_sale_setups
        format.html { render :action => "edit" }
        format.xml  { render :xml => @weekly_sale_setup_liquid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_sale_setup_liquids/1
  # DELETE /weekly_sale_setup_liquids/1.xml
  def destroy
    @weekly_sale_setup_liquid = WeeklySaleSetupLiquid.find(params[:id])
    @weekly_sale_setup_liquid.destroy

    respond_to do |format|
      format.html { redirect_to(weekly_sale_setup_liquids_url) }
      format.xml  { head :ok }
    end
  end

  private 

  def list_accounts
   @accounts = Account.with_permissions_to(:read).all(:order => "number")
  end

  def list_weekly_sale_setups
   @weekly_sale_setups = WeeklySaleSetup.with_permissions_to(:read).all(:order => "name")
  end

end
