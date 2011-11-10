class Admin::AdminLogsController < Admin::BaseController
  
  # GET /admin_logs
  # GET /admin_logs.xml
  def index
    @admin_logs = AdminLog.order("created_at DESC").paginate(:page => params[:page])
  end
  
end
