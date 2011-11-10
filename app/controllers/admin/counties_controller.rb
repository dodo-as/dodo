class Admin::CountiesController < Admin::BaseController

  attr_accessor :county
  around_filter AdminLog.log(:county), :only => [:update, :create]

  # GET /counties
  # GET /counties.xml
  def index
    @counties = County.where(:is_visible => true)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @counties }
    end
  end

  # GET /counties/1
  # GET /counties/1.xml
  def show
    @county = County.find(params[:id])
    @county_tax_zone = CountyTaxZone.where(:county_id => @county.id)[0]     
    @tax_zone = @county_tax_zone.tax_zone
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @county }
    end
  end

  # GET /counties/new
  # GET /counties/new.xml
  def new
    @county = County.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @county }
    end
  end

  # GET /counties/1/edit
  def edit
    @county = County.find(params[:id])
    @county_tax_zone = CountyTaxZone.where(:county_id => @county.id)[0]      
    unless  @county_tax_zone.nil? 
	@tax_zone = @county_tax_zone.tax_zone
        @from = @county_tax_zone.from
        @number = @tax_zone.number
    end       
  end

  # POST /counties
  # POST /counties.xml
  def create
    @county = County.new(params[:county])
    respond_to do |format|
      if @county.save
        format.html { redirect_to([:admin, @county], :notice => 'County was successfully created.') }
        format.xml  { render :xml => @county, :status => :created, :location => @county }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @county.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /counties/1
  # PUT /counties/1.xml
  def update
    @county = County.find(params[:id])    
    county_tax_zone = CountyTaxZone.where(:county_id => @county.id)[0]   
    respond_to do |format|
      if county_tax_zone.update_attributes(params[:county]["county_tax_zone"]) and county_tax_zone.update_attributes(params[:county]["tax_zone"])
        format.html { redirect_to([:admin, @county], :notice => 'County was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @county.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /counties/1
  # DELETE /counties/1.xml
  def destroy
    @county = County.find(params[:id]) 
    @county.is_visible = false  
    state = @county.save  	
    respond_to do |format|
      format.html { redirect_to(admin_counties_url) }
      format.xml  { head :ok }
    end
  end
end
