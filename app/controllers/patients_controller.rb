class PatientsController < ApplicationController
  before_action :set_patient, only: [ :show, :edit, :update, :destroy ]

  # GET /patients
  def index
    @patients = Patient.all
    respond_to do |format|
      format.html
      format.json { render json: @patients }
    end
  end

  # GET /patients/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @patient }
    end
  end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients
  def create
    @patient = Patient.new(patient_params)

    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: "Patient was successfully created." }
        format.json { render json: @patient, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /patients/1
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: "Patient was successfully updated." }
        format.json { render json: @patient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1
  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to patients_url, notice: "Patient was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to patients_url, alert: "Patient not found." }
      format.json { render json: { error: "Patient not found" }, status: :not_found }
    end
  end

  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :email, :date_of_birth)
  end
end
