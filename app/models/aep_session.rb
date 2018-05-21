class AepSession < ActiveRecord::Base

  has_many :aep_attendances, :include => ({:aep_registration => {:student_registration => :student}}), :dependent => :destroy, :order => "students.last_name asc"
  belongs_to :season

  accepts_nested_attributes_for :aep_attendances

  delegate :term, to: :season
  before_create :set_enrollment_count

  def attendees
    aep_attendances.present.count
  end

  private

  def set_enrollment_count
    self.enrollment_count = AepRegistration.current.paid.count
  end


end
