# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_locale_now, :authenticate_user!, :init_auth
  before_filter :company_required, :if => proc { current_user }
  
  helper :all # include all helpers, all the time
  
  attr_accessor :me
  attr_accessor :company
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => 'fd4b65ee1595df77234ee4ea6a277542'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  protected

  def set_locale_now
    I18n.locale = session[:locale] = params[:locale] || session[:locale] || I18n.default_locale
  end

  def init_auth   
    company_id = session[:company_id]
    Authorization.current_user = current_user
    @me = current_user
    current_user.current_company_id = company_id if company_id
    if @me!=nil
        @company = @me.current_company
    end
  end

  def company_required
    if current_user.current_company.nil?
      current_user.current_company = current_user.companies.first
    end    
    
    if not current_user.current_company.nil?
      return true
    end

    flash[:notice]='You must have at least one company to work with'
    redirect_to :controller => "companies", :action => "index"
    return false
  end

  def permission_denied
    msg = I18n.t("access_denied")
    flash[:error] = msg
    logger.info "Error: #{msg}, user: #{current_user}, url: #{request.fullpath}, pid: #{Process.pid}, Time: #{Time.now}"
    redirect_to root_url
  end

  def user_property name, default
    fn = controller_name + "." + name.to_s
    foo = search_param(String(name).split('.'), params) || current_user.get_property( fn ) || default
    current_user.set_property( fn, foo)
  end

  def search_param name_arr, dict
    if name_arr == nil
      return nil
    end
    if dict == nil
      return nil
    end
    if name_arr.count == 1
      return dict[name_arr[0]]
    end
    return search_param(name_arr[1..name_arr.count], dict[name_arr[0]])
  end
  
  def user_company_property name, default

    fn = "company_#{current_user.current_company.id.to_s}.#{controller_name}.#{name.to_s}"
    foo = search_param(String(name).split('.'), params) || current_user.get_property( fn ) || default
    current_user.set_property( fn, foo)
  end

  def to_s
    self.class.to_s
  end
  
end
