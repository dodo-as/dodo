class JournalsController < ApplicationController
  include PeriodController

  before_filter :set_readonly
  before_filter :find_units_all, :only => [:new, :edit, :show]
  before_filter :find_cars_all, :only => [:new, :edit, :show]
  before_filter :find_projects_all, :only => [:new, :edit, :show]
  before_filter :find_accounts_all, :only => [:new, :edit, :show]
  filter_resource_access

  # GET /journals
  # GET /journals.xml
  def index
    @journals = period_filter(
      Journal.with_permissions_to(:index).order(
        "number, journal_date desc, journal_type_id")).paginate(
          {:page => params[:page]})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @journals }
    end
  end

  
  # GET /journals/1
  # GET /journals/1.xml
  def show
    @readonly = true
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @journal }
    end
  end
  
  # GET /journals/new
  # GET /journals/new.xml
  def new
    @journal = Journal.new :journal_type_id => params[:journal_type_id]
    if !@journal.journal_type
      raise "No journal type specified"
    end
    @journal.number = @journal.journal_type.get_next_number(@me.current_company)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @journal }
    end
  end

  # GET /journals/1/edit
  def edit
  end

  # POST /journals
  # POST /journals.xml
  def create
    respond_to do |format|
      raise Authorization::NotAuthorized unless permitted_to? :create, @journal
      Journal.transaction do
        begin
          
          @journal = Journal.new(params[:journal])
          @journal.company = @me.current_company
          params[:journal_operations].each do
            |key, value|
            op = JournalOperation.new(value)
            op.company = @me.current_company
            @journal.journal_operations.push op 
          end
          @journal.save!

          cnt = @journal.journal_type.counter(@me.current_company)
          if cnt.adjust_outside_of_sequence
            cnt.counter = @journal.number+1
            cnt.save
          end
          
          flash[:notice] = 'Journal was successfully created.'
          format.html { redirect_to(@journal) }
          format.xml  { render :xml => @journal, :status => :created, :location => @journal }
        rescue ActiveRecord::Rollback
          format.html { render :action => "new" }
          format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /journals/1
  # PUT /journals/1.xml
  def update
    respond_to do |format|
      Journal.transaction do
        begin

          @journal.journal_operations.each do
            |op|
            if op.closed_operation then
              op.closed_operation.journal_operations.each do
                |op2|
                op2.closed_operation = nil
                op2.save
              end
            end
          end

          @journal.update_attributes(params[:journal]) or raise ActiveRecord::Rollback
          @journal.journal_operations.clear
          params[:journal_operations].each do
            |key, value|
            op = JournalOperation.new(value)
            op.company = @me.current_company
            @journal.journal_operations.push op 
          end
          @journal.save!
          
          cnt = @journal.journal_type.counter(@me.current_company)
          if cnt.adjust_outside_of_sequence
            cnt.counter = @journal.number+1
            cnt.save
          end
          
          flash[:notice] = 'Journal was successfully updated.'
          format.html { redirect_to(@journal) }
          format.xml  { head :ok }

        rescue ActiveRecord::Rollback
          format.html { render :action => "edit" }
          format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /journals/1
  # DELETE /journals/1.xml
  def destroy
    @journal.destroy

    respond_to do |format|
      format.html { redirect_to(journals_url) }
      format.xml  { head :ok }
    end
  end

  private 
  
  def find_accounts_all
    tmp =
      Account.where(:company_id => @me.current_company.id).order(:number)
    @accounts_all = []
    tmp.each do
      |a|
      if a.has_ledger then
        a.ledgers.each do
          |l|
          @accounts_all << {:name => "#{a.number} #{a.name} - #{l.name}", :value => "#{a.id}.#{l.id}"}
        end
      else
        @accounts_all << {:name => "#{a.number} #{a.name}", :value => a.id, :vat_account => a.vat_account}
      end
    end
  end
  
  def find_units_all
    @units_all =
      Unit.where(:company_id => @me.current_company.id).order(:name)
  end

  def find_cars_all
    @cars_all =
      Car.where(:company_id => @me.current_company.id).order(:name)
  end
  
  def find_projects_all
    @projects_all =
      Project.where(:company_id => @me.current_company.id).order(:name)
  end
  
  def set_readonly
    @readonly=false
  end
  
end
