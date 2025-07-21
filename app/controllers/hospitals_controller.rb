class HospitalsController < ApplicationController
  before_action :set_hospital, only: [ :show, :edit, :update, :destroy ]

  # GET /hospitals
  def index
    @pagy, @hospitals = pagy(Hospital.all)
    respond_to do |format|
      format.html
      format.json { render json: @hospitals }
    end
  end

  # GET /hospitals/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @hospital }
    end
  end

  # GET /hospitals/new
  def new
    @hospital = Hospital.new
  end

  # GET /hospitals/1/edit
  def edit
  end

  # POST /hospitals
  def create
    @hospital = Hospital.new(hospital_params)

    respond_to do |format|
      if @hospital.save
        format.html { redirect_to @hospital, notice: "Hospital was successfully created." }
        format.json { render json: @hospital, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hospitals/1
  def update
    respond_to do |format|
      if @hospital.update(hospital_params)
        format.html { redirect_to @hospital, notice: "Hospital was successfully updated." }
        format.json { render json: @hospital }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hospitals/1
  def destroy
    @hospital.destroy
    respond_to do |format|
      format.html { redirect_to hospitals_url, notice: "Hospital was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_hospital
    @hospital = Hospital.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to hospitals_url, alert: "Hospital not found." }
      format.json { render json: { error: "Hospital not found" }, status: :not_found }
    end
  end

  def hospital_params
    params.require(:hospital).permit(:name, :address, :phone, :email, :registration_number, :active, :status)
  end
end
