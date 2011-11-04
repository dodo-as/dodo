class Admin::UsersController < Admin::BaseController

  attr_accessor :user
  around_filter AdminLog.log(:user), :only => [:update, :create]

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
        flash[:notice] = :successful_signup
        format.html { redirect_to([:admin, @user]) }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
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

  def index
    @users = User.order(:email).includes(:companies).paginate({:page => params[:page]})

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
        format.html { redirect_to([:admin, @user]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end

  def edit
    @user = User.find(params[:id])
    3.times {|i| @user.assignments.build }
  end

end
