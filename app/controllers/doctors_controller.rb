class DoctorsController < ApplicationController
  before_action :set_doctor, only: [ :show, :edit, :update, :destroy ]
  before_action :require_doctor_access, only: [ :dashboard ]

  # GET /doctor/dashboard
  def dashboard
    @doctor = current_user
    @upcoming_appointments = @doctor.appointments.upcoming.order(:appointment_date)
    @total_patients = @doctor.total_patients_count
    @recent_appointments = @doctor.appointments.order(appointment_date: :desc).limit(5)
  end

  # GET /doctors
  def index
    @doctors = Doctor.all
    respond_to do |format|
      format.html
      format.json { render json: @doctors }
    end
  end

  # GET /doctors/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @doctor }
    end
  end

  # GET /doctors/new
  def new
    @doctor = Doctor.new
    @hospitals = Hospital.all
    @clinics = Clinic.all
  end

  # GET /doctors/1/edit
  def edit
    @hospitals = Hospital.all
    @clinics = Clinic.all
  end

  # POST /doctors
  def create
    @doctor = Doctor.new(doctor_params)

    respond_to do |format|
      if @doctor.save
        format.html { redirect_to @doctor, notice: "Doctor was successfully created." }
        format.json { render json: @doctor, status: :created }
      else
        @hospitals = Hospital.all
        @clinics = Clinic.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @doctor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /doctors/1
  def update
    respond_to do |format|
      if @doctor.update(doctor_params)
        format.html { redirect_to @doctor, notice: "Doctor was successfully updated." }
        format.json { render json: @doctor }
      else
        @hospitals = Hospital.all
        @clinics = Clinic.all
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @doctor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /doctors/1
  def destroy
    @doctor.destroy
    respond_to do |format|
      format.html { redirect_to doctors_url, notice: "Doctor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_doctor
    @doctor = Doctor.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to doctors_url, alert: "Doctor not found." }
      format.json { render json: { error: "Doctor not found" }, status: :not_found }
    end
  end

  def doctor_params
    params.require(:doctor).permit(:first_name, :last_name, :specialization, :hospital_id, :clinic_id, :email, :password, :password_confirmation)
  end

  def require_doctor_access
    require_user_type("doctor")
  end
end
