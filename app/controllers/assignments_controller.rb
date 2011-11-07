class AssignmentsController < ApplicationController
    
    def new
        @assignment = Assignment.new
        @other_info = {:comp => nil, :num => nil}
        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => [@assignment] }
        end
    end
    
    def create
        @assignment = Assignment.new(params[:assignment])
        company_params = params[:company]
        comp = Company.where(:name => company_params[:name]).where(:organization_number => company_params[:organization_number])
        if comp.count == 1
            @assignment.company = comp[0] 
        end
        @assignment.user = @me
        @assignment.role = Role.where(:name => "none")[0]
        if comp.count == 1 && @assignment.save
            redirect_to(root_path)
        else
            redirect_to(root_path)
        end
    end
    
end
