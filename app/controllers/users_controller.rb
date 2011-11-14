require "random_pass_generator"

class UsersController < ApplicationController
        
    filter_resource_access
    
    attr_accessor :user
    around_filter Log.log(:user), :only => [:update, :create]
    def new
      @user = User.new
          respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml => @journal }
      end
    end
    
    def create
        @user = User.new(params[:user])
        @user.password = RandSmartPass()
        @user.current_company = @me.current_company
        respond_to do |format|
      if @user.save
        UserNotifier.send_mail(@user).deliver
        assignment = Assignment.new
        assignment.role = Role.where( :name => "none")[0]
        assignment.user = @user
        assignment.company = @me.current_company
        assignment.save
        flash[:notice] = "User created"
        format.html { redirect_to users_path }
        format.xml { render :xml => @user}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
    end

    def index
    @users = @company.users.order(:email).includes(:companies).paginate({:page => params[:page]})
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end
  
    def update
    respond_to do |format|
      # don't update password if blank
      if params[:user][:password].blank?
        params[:user].delete :password
        params[:user].delete :password_confirmation
      end
      if @user.update_attributes(params[:user])
        flash[:notice] = t(:update_success, :scope => :users)
        if @me.role_symbols.count(:user_admin) > 0
            format.html { redirect_to users_path }
        else
            format.html { redirect_to root_path }
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

    def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
    
    def edit
        3.times { @user.assignments.build }
    end
end
