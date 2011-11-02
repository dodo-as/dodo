
class CompaniesController < ApplicationController

  before_filter :find_company

  def find_company
    @company = @me.current_company
  end

  # GET /companies/1
  # GET /companies/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /companies/1/edit
  def edit
    3.times {@company.assignments.build }
  end

  # PUT /companies/1
  # PUT /companies/1.xml
  def update

    respond_to do |format|
      Company.transaction do
        if @company.update_attributes(params[:company]) and 
            @company.update_journal_types(params[:journal_type])
          flash[:notice] = 'Company was successfully updated.'
          format.html { redirect_to(edit_company_path) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

end
