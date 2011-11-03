class VatAccountPeriodsController < ApplicationController
  #filter_resource_access
  
  def index
  end

  def create
  end

  def new
  end

  def edit
  end

  def show
  end

  def update
    @period = VatAccountPeriod.find(params[:id])
    @period.attributes = params[:vat_account_period]
    respond_to do |format|
      if @period.save!
        flash[:notice] = t('vat_period.update_success')
        format.html { redirect_to(:controller=>'vat_accounts', :action=>'index') }
        format.xml  { head :ok }
      else
        format.html { render :text => "omg strange period update" }#:action => "edit" }
        format.xml  { render :xml => @period.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
  end

end
