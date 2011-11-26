class Admin::TaxZoneTaxesController < Admin::BaseController
 
  # GET /tax_zone_taxes
  # GET /tax_zone_taxes.xml
  
  attr_accessor :tax_zone_tax
  around_filter AdminLog.log(:tax_zone_tax), :only => [:update, :create]
  
  def index
    @tax_zone_taxes = TaxZoneTax.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tax_zone_taxes }
    end
  end

  # GET /tax_zone_taxes/1
  # GET /tax_zone_taxes/1.xml
  def show
    @tax_zone_tax = TaxZoneTax.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tax_zone_tax }
    end
  end

  # GET /tax_zone_taxes/new
  # GET /tax_zone_taxes/new.xml
  def new
    @tax_zone_tax = TaxZoneTax.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tax_zone_tax }
    end
  end

  # GET /tax_zone_taxes/1/edit
  def edit
    @tax_zone_tax = TaxZoneTax.find(params[:id])
  end

  # POST /tax_zone_taxes
  # POST /tax_zone_taxes.xml
  def create
    @tax_zone_tax = TaxZoneTax.new(params[:tax_zone_tax])

    respond_to do |format|
      if @tax_zone_tax.save
        format.html { redirect_to admin_tax_zone_path(@tax_zone_tax.tax_zone) }
        #~ format.xml  { render :xml => @tax_zone_tax, :status => :created, :location => @tax_zone_tax }
      else
        #~ format.html { render :action => "new" }
        format.xml  { render :xml => @tax_zone_tax.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tax_zone_taxes/1
  # PUT /tax_zone_taxes/1.xml
  def update
    @tax_zone_tax = TaxZoneTax.find(params[:id])

    respond_to do |format|
      if @tax_zone_tax.update_attributes(params[:tax_zone_taxes])
        format.html { redirect_to([:admin,@tax_zone_tax], :notice => 'Tax zone tax was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tax_zone_tax.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tax_zone_taxes/1
  # DELETE /tax_zone_taxes/1.xml
  def destroy
    @tax_zone_tax = TaxZoneTax.find(params[:id])
    @tax_zone_tax.is_visible = false
    @tax_zone_tax.save    

    respond_to do |format|
      format.html { redirect_to(admin_tax_zone_taxes_url) }
      format.xml  { head :ok }
    end
  end
end
