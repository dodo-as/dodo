class CarsController < ApplicationController
  
  before_filter :set_readonly
  
  filter_resource_access

  attr_accessor :car
  around_filter Log.log(:car), :only => [:update, :create]
  

  # GET /cars
  # GET /cars.xml
  def index
    @cars = Car.with_permissions_to(:index).all(:order => "lower(name)")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cars }
    end
  end

  # GET /cars/1
  # GET /cars/1.xml
  def show
    @readonly = true
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @car }
    end
  end

  # GET /cars/new
  # GET /cars/new.xml
  def new
    @car = Car.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @car }
    end
  end

  # GET /cars/1/edit
  def edit
  end

  # POST /cars
  # POST /cars.xml
  def create
    @car = Car.new(params[:car])
    @car.company = @me.current_company
    raise Authorization::NotAuthorized unless permitted_to? :create, @car

    respond_to do |format|
      if @car.save
        flash[:notice] = 'Car was successfully created.'
        format.html { redirect_to(@car) }
        format.xml  { render :xml => @car, :status => :created, :location => @car }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @car.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cars/1
  # PUT /cars/1.xml
  def update
    respond_to do |format|
      if @car.update_attributes(params[:car])
        flash[:notice] = 'Car was successfully updated.'
        format.html { redirect_to(@car) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @car.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.xml
  def destroy
    @car.destroy

    respond_to do |format|
      format.html { redirect_to(cars_url) }
      format.xml  { head :ok }
    end
  end
  
  def set_readonly
    #before_filter :set_readonly
      @readonly=false
  end
end
