class TravelLogsController < ApplicationController

  # POST /travel_logs
  # POST /travel_logs.xml
  def create
    @travel_log = TravelLog.new(params[:travel_log])

    respond_to do |format|
      if @travel_log.save
        format.html { redirect_to(edit_car_path @travel_log.car, :notice => 'Travel log was successfully created.') }
        format.xml  { render :xml => @travel_log, :status => :created, :location => @travel_log }
      else
        format.html { render :action => "new" }
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
      # stay on cars page
      format.html { redirect_to(edit_car_path @travel_log.car) }
      format.xml  { head :ok }
    end
  end

end
