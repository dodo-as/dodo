class WeeklySaleSetupProductGroupsController < ApplicationController
  # GET /weekly_sale_setup_product_groups
  # GET /weekly_sale_setup_product_groups.xml
  def index
    @weekly_sale_setup_product_groups = WeeklySaleSetupProductGroup.with_permissions_to(:index).all(:order => "name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weekly_sale_setup_product_groups }
    end
  end

  # GET /weekly_sale_setup_product_groups/1
  # GET /weekly_sale_setup_product_groups/1.xml
  def show
    @weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weekly_sale_setup_product_group }
    end
  end

  # GET /weekly_sale_setup_product_groups/new
  # GET /weekly_sale_setup_product_groups/new.xml
  def new
    @weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.new
    list_accounts
    list_weekly_sale_setups
    list_projects

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @weekly_sale_setup_product_group }
    end
  end

  # GET /weekly_sale_setup_product_groups/1/edit
  def edit
    @weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.find(params[:id])
    list_accounts
    list_weekly_sale_setups
    list_projects
  end

  # POST /weekly_sale_setup_product_groups
  # POST /weekly_sale_setup_product_groups.xml
  def create
    @weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.new(params[:weekly_sale_setup_product_group])
    @weekly_sale_setup_product_group.company_id = @me.current_company.id

    respond_to do |format|
      if @weekly_sale_setup_product_group.save
        format.html { redirect_to(@weekly_sale_setup_product_group, :notice => 'Weekly sale setup product group was successfully created.') }
        format.xml  { render :xml => @weekly_sale_setup_product_group, :status => :created, :location => @weekly_sale_setup_product_group }
      else
        list_accounts
        list_weekly_sale_setups
        list_projects
        format.html { render :action => "new" }
        format.xml  { render :xml => @weekly_sale_setup_product_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /weekly_sale_setup_product_groups/1
  # PUT /weekly_sale_setup_product_groups/1.xml
  def update
    @weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.find(params[:id])

    respond_to do |format|
      if @weekly_sale_setup_product_group.update_attributes(params[:weekly_sale_setup_product_group])
        format.html { redirect_to(@weekly_sale_setup_product_group, :notice => 'Weekly sale setup product group was successfully updated.') }
        format.xml  { head :ok }
      else
        list_accounts
        list_weekly_sale_setups
        list_projects
        format.html { render :action => "edit" }
        format.xml  { render :xml => @weekly_sale_setup_product_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_sale_setup_product_groups/1
  # DELETE /weekly_sale_setup_product_groups/1.xml
  def destroy
    @weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.find(params[:id])
    @weekly_sale_setup_product_group.destroy

    respond_to do |format|
      format.html { redirect_to(weekly_sale_setup_product_groups_url) }
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

  def list_projects
   @projects = Project.with_permissions_to(:read).all(:order => "name")
  end

end
