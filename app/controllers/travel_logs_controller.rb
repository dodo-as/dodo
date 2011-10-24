class TravelLogsController < ApplicationController
  # GET /travel_logs
  # GET /travel_logs.xml
  def index
    @travel_logs = TravelLog.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @travel_logs }
    end
  end

  # GET /travel_logs/1
  # GET /travel_logs/1.xml
  def show
    @travel_log = TravelLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @travel_log }
    end
  end

  # GET /travel_logs/new
  # GET /travel_logs/new.xml
  def new
    @travel_log = TravelLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @travel_log }
    end
  end

  # GET /travel_logs/1/edit
  def edit
    @travel_log = TravelLog.find(params[:id])
  end

  # POST /travel_logs
  # POST /travel_logs.xml
  def create
    @travel_log = TravelLog.new(params[:travel_log])

    respond_to do |format|
      if @travel_log.save
        format.html { redirect_to(@travel_log, :notice => 'Travel log was successfully created.') }
        format.xml  { render :xml => @travel_log, :status => :created, :location => @travel_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @travel_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /travel_logs/1
  # PUT /travel_logs/1.xml
  def update
    @travel_log = TravelLog.find(params[:id])

    respond_to do |format|
      if @travel_log.update_attributes(params[:travel_log])
        format.html { redirect_to(@travel_log, :notice => 'Travel log was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @travel_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_logs/1
  # DELETE /travel_logs/1.xml
  def destroy
    @travel_log = TravelLog.find(params[:id])
    @travel_log.destroy

    respond_to do |format|
      format.html { redirect_to(travel_logs_url) }
      format.xml  { head :ok }
    end
  end
end
