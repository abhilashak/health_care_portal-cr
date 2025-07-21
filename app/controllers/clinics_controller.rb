class ClinicsController < ApplicationController
  before_action :set_clinic, only: [ :show, :edit, :update, :destroy ]

  # GET /clinics
  def index
    @clinics = Clinic.all
    respond_to do |format|
      format.html
      format.json { render json: @clinics }
    end
  end

  # GET /clinics/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @clinic }
    end
  end

  # GET /clinics/new
  def new
    @clinic = Clinic.new
  end

  # GET /clinics/1/edit
  def edit
  end

  # POST /clinics
  def create
    @clinic = Clinic.new(clinic_params)

    respond_to do |format|
      if @clinic.save
        format.html { redirect_to @clinic, notice: "Clinic was successfully created." }
        format.json { render json: @clinic, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clinics/1
  def update
    respond_to do |format|
      if @clinic.update(clinic_params)
        format.html { redirect_to @clinic, notice: "Clinic was successfully updated." }
        format.json { render json: @clinic }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clinics/1
  def destroy
    @clinic.destroy
    respond_to do |format|
      format.html { redirect_to clinics_url, notice: "Clinic was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_clinic
    @clinic = Clinic.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to clinics_url, alert: "Clinic not found." }
      format.json { render json: { error: "Clinic not found" }, status: :not_found }
    end
  end

  def clinic_params
    params.require(:clinic).permit(:name, :address, :phone, :email, :registration_number, :active, :status)
  end
end
