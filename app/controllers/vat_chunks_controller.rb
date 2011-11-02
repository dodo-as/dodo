class VatChunksController < ApplicationController

  before_filter :find_vat_chunk, :only => [:edit, :update, :show, :destroy]

  def find_vat_chunk
    @vat_chunk = VatChunk.where(:id => params[:id], :company_id => @me.current_company).first
  end

  # GET /vat_chunks
  # GET /vat_chunks.xml
  def index
    @vat_chunks = VatChunk.where(:company_id => @me.current_company)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vat_chunks }
    end
  end

  # GET /vat_chunks/1
  # GET /vat_chunks/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vat_chunk }
    end
  end

  # GET /vat_chunks/new
  # GET /vat_chunks/new.xml
  def new
    @vat_chunk = VatChunk.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vat_chunk }
    end
  end

  # GET /vat_chunks/1/edit
  def edit
  end

  # POST /vat_chunks
  # POST /vat_chunks.xml
  def create
    @vat_chunk = VatChunk.new(params[:vat_chunk])
    @vat_chunk.company = @me.current_company

    respond_to do |format|
      if @vat_chunk.save
        format.html { redirect_to(@vat_chunk, :notice => 'Vat chunk was successfully created.') }
        format.xml  { render :xml => @vat_chunk, :status => :created, :location => @vat_chunk }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @vat_chunk.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /vat_chunks/1
  # PUT /vat_chunks/1.xml
  def update
    respond_to do |format|
      @vat_chunk.company = @me.current_company
      if @vat_chunk.update_attributes(params[:vat_chunk])
        format.html { redirect_to(@vat_chunk, :notice => 'Vat chunk was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vat_chunk.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /vat_chunks/1
  # DELETE /vat_chunks/1.xml
  def destroy
    @vat_chunk.destroy

    respond_to do |format|
      format.html { redirect_to(vat_chunks_url) }
      format.xml  { head :ok }
    end
  end
end
