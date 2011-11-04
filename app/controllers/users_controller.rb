class UsersController < ApplicationController
        
    filter_resource_access
        
    def new
    @user = User.new
          respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml => @journal }
        end
    end
    
    def create
        @user = User.new(params[:user])

        respond_to do |format|
      if @user.save
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
  @user = User.find(params[:id])

    respond_to do |format|
      # don't update password if blank
      if params[:user][:password].blank?
        params[:user].delete :password
        params[:user].delete :password_confirmation
      end
      if @user.update_attributes(params[:user])
        flash[:notice] = t(:update_success, :scope => :users)
        format.html { render :show }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

    def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
    
    def edit
    @user = User.find(params[:id])
    
    end

end
