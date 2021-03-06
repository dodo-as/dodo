class LedgersController < ApplicationController

  before_filter :load_ledger, :only => [:show, :edit, :update, :destroy]
  before_filter :right_company, :only => [:show, :edit, :update, :destroy]
  
  attr_accessor :ledger
  around_filter Log.log(:ledger), :only => [:update, :create]
  
  def load_ledger
    @ledger = Ledger.find(params[:id])

    if params[:account_id] && params[:account_id].to_i != 0
      raise "account_id incorrect" if @ledger.account_id != params[:account_id].to_i
    end
  end

  def right_company
    if @me.companies.include? @ledger.account.company
      @me.current_company = @ledger.account.company
      return true
    end

    flash[:notice]='You can only manage your own ledgers. Go away.'
    redirect_to :action => "index"
    return false 
  end
  
  def create

    @ledger = Ledger.new(params[:ledger])   

    raise "account does not belong to active company" if @ledger.account.company != @me.current_company
    if @ledger.credit_days.blank?
      @ledger.credit_days = 0
    end
    respond_to do |format|
        if @ledger.save  
            format.json { render :json => @ledger.to_json(:include => {:unit => {}, :project => {} }) }
            format.html { redirect_to @ledger, :notice => "Ledger created" }
            format.xml { head :ok }
        else
        
          #~ flash[:ledger] = @account
          #~ raise @ledger.errors.full_messages.join(", ")
            format.html { render :action => 'edit'}
        end
    end
  end

  def update
    @ledger.update_attributes!(params[:ledger])
    respond_to do |format|
      format.html do
        flash[:notice] = t(:ledger_saved, :scope => :ledgers, :name => @ledger.name)
        redirect_to edit_account_path(@ledger.account)
      end
      format.json { head :ok }
      format.xml { head :ok }
    end
  end

  def new
    @account = Account.find(params[:account_id])
    @ledger = Ledger.new(:account => @account)
    #~ @ledger.county_ledgers.build
    # @ledger.address = Address.new
    respond_to do |format|
      #~ format.html { render :partial => "accounts/ledger_form", :locals => {:account => @account, :ledger => @ledger} }
              format.html { render :action => 'edit', :locals => {:account => @account, :ledger => @ledger} }

    end
  end

  def show
    respond_to do |format|
      #~ format.json { render :json => @ledger.to_json(:include => [:account,
                                                                 #~ :address,
                                                                 #~ :unit,
                                                                 #~ :project]
                                                    #~ )
      #~ }
      @account = @ledger.account
      #~ format.html { render :partial => "form", :locals => {:account => @account, :ledger => @ledger} }
        format.html
        format.xml  { render :xml => @ledger, :status => :created, :location => @ledger }

    end
  end

end
