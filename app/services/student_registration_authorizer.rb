class StudentRegistrationAuthorizer

  class << self
    def new_student_enrollment_forbidden?
      registration_closed? || open_enrollment_not_active?
    end

    def registration_closed?
       current_season.closed?
    end

    def open_enrollment_not_active?
      !open_enrollment_active?
    end

    def can_register? student
      allowed_to_register_during_period?(student) ? OpenStruct.new(:answer=> true) : OpenStruct.new(:answer => false, :message =>"New student enrollment is closed")

    end

    private


    def open_enrollment_active?
      current_season.open_enrollment_period_is_active?
    end

    def can_register_as_returning_student? student
      (student.registered_last_year? && returning_student_enrollment_active?)
    end

    def returning_student_enrollment_active?
      current_season.pre_enrollment_enabled?
    end

    def allowed_to_register_during_period? student
      can_register_as_returning_student?(student) || open_enrollment_active?
    end

    def current_season
      Season.current
    end

  end
end
