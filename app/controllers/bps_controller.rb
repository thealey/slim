class BpsController < ApplicationController
  # GET /bps
  # GET /bps.json
  def index
    @bps = Bp.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bps }
    end
  end

  # GET /bps/1
  # GET /bps/1.json
  def show
    @bp = Bp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bp }
    end
  end

  # GET /bps/new
  # GET /bps/new.json
  def new
    @bp = Bp.new
    @bp.person_id = current_person.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bp }
    end
  end

  # GET /bps/1/edit
  def edit
    @bp = Bp.find(params[:id])
  end

  # POST /bps
  # POST /bps.json
  def create
    @bp = Bp.new(params[:bp])

    respond_to do |format|
      if @bp.save
        format.html { redirect_to @bp, notice: 'Bp was successfully created.' }
        format.json { render json: @bp, status: :created, location: @bp }
      else
        format.html { render action: "new" }
        format.json { render json: @bp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bps/1
  # PUT /bps/1.json
  def update
    @bp = Bp.find(params[:id])

    respond_to do |format|
      if @bp.update_attributes(params[:bp])
        format.html { redirect_to @bp, notice: 'Bp was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bps/1
  # DELETE /bps/1.json
  def destroy
    @bp = Bp.find(params[:id])
    @bp.destroy

    respond_to do |format|
      format.html { redirect_to bps_url }
      format.json { head :no_content }
    end
  end
end
