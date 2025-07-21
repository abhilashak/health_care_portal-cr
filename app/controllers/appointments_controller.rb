class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]

  # GET /appointments
  def index
    @pagy, @appointments = pagy(Appointment.includes(:doctor, :patient).order(appointment_date: :desc))
    respond_to do |format|
      format.html
      format.json { render json: @appointments }
    end
  end

  # GET /appointments/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @appointment }
    end
  end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
    @doctors = Doctor.limit(50)
    @patients = Patient.limit(50)
  end

  # GET /appointments/1/edit
  def edit
    @doctors = Doctor.limit(50)
    @patients = Patient.limit(50)
  end

  # POST /appointments
  def create
    @appointment = Appointment.new(appointment_params)

    respond_to do |format|
      if @appointment.save
        format.html { redirect_to @appointment, notice: "Appointment was successfully created." }
        format.json { render json: @appointment, status: :created }
      else
        @doctors = Doctor.limit(50)
        @patients = Patient.limit(50)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1
  def update
    respond_to do |format|
      if @appointment.update(appointment_params)
        format.html { redirect_to @appointment, notice: "Appointment was successfully updated." }
        format.json { render json: @appointment }
      else
        @doctors = Doctor.limit(50)
        @patients = Patient.limit(50)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1
  def destroy
    @appointment.destroy
    respond_to do |format|
      format.html { redirect_to appointments_url, notice: "Appointment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to appointments_url, alert: "Appointment not found." }
      format.json { render json: { error: "Appointment not found" }, status: :not_found }
    end
  end

  def appointment_params
    params.require(:appointment).permit(:doctor_id, :patient_id, :appointment_date, :status, :duration_minutes, :appointment_type, :notes)
  end
end
