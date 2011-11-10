class LogsController < ApplicationController
  # GET /logs
  # GET /logs.xml
  def index
    @logs = Log.where(:company_id => @company).order("created_at DESC").paginate(:page => params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logs }
    end
  end
  
end
