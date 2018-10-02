class StudentRegistrationsController < ApplicationController
  before_action :get_registration, only:[:show, :destroy, :update, :confirmation]
  def new
    if params[:student_id]
      @student = current_parent.students.find(params[:student_id])
      redirect_to @student and return unless can_register? @student
      @student_registration = @student.student_registrations.build
    else
      redirect_to dashboard_path, :notice => "No student found to create registration"
    end
  end


  def create
    @student_registration = StudentRegistration.new(student_registration_params)
    if @student_registration.valid?
      @student_registration.save!
      WaitListService.activate_if_enrollment_limit_reached
      redirect_to  dashboard_path, notice: "Student registration successfully created"
    else
      render :new
    end
  end

  def destroy
    registration = current_parent.student_registrations.find(params[:id])
    registration.destroy
    redirect_to dashboard_path
  end

  def confirmation
    @student = @student_registration.student
    @payment = @student_registration.payment
    render :confirmation, :layout => "receipt"
  end

   
  def update
    #FIXME implement udate method
  end
   
  def grouping
   StudentRegistration.current.confirmed
  end

  private

  def get_registration 
    @student_registration = current_parent.student_registrations.find(params[:id])
  end 

  def open_enrollment
    current_season.open_enrollment_period_is_active?
  end

  def pre_enrollment
    current_season.pre_enrollment_enabled?
  end

  def can_register? student
    (student.registered_last_year? && pre_enrollment) || open_enrollment 
  end

  protected
  def begin_of_association_chain
    current_parent
  end

  def student_registration_params
    params.require(:student_registration).permit(
  :school, :grade, :size_cd, :medical_notes, 
    :academic_notes, :academic_assistance, :student_id, :season_id, 
    :status_cd, :first_report_card_received, :first_report_card_expected_date, 
    :first_report_card_received_date, :second_report_card_received, 
    :second_report_card_expected_date, :second_report_card_received_date,
    :report_card_exempt)
  end

end
