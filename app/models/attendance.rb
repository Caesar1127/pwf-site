class Attendance < ApplicationRecord
  belongs_to :attendance_sheet
  belongs_to :student_registration, ->{includes :student}
  has_one :student,  through: :student_registration
  has_one :group, through: :student_registration

  validates_uniqueness_of :student_registration_id, :scope => [:session_date, :attendance_sheet_id]

  scope :present, -> {where(attended: true)}
  scope :absent, -> {where(attended:false)}
  scope :ordered, ->{order("students.last_name, students.first_name")}

  delegate :current_present_attendances, to: :student

  def self.current
    self.joins(:student_registration).merge(StudentRegistration.current)
  end

  def self.with_student
    self.joins(:student_registration =>:student)
      .merge(StudentRegistration.confirmed)
      .preload(:student).select("student_registration_id, attended, attendances.id, students.first_name, students.last_name")
  end

  def self.as_of date
    joins(:attendance_sheet).where("attendance_sheets.session_date <= ?",  date)
  end

  def self.attendance_summary
    current.present
      .select("student_registration_id, count(attended)")
      .group("student_registration_id")
  end

  def self.student_registration_ids_with_count_greater_than_or_eq val
    attendance_count_greater_than_or_eq(val).size.keys
  end

  def self.attendance_count_greater_than_or_eq val
    attendance_summary.having("count(attended) >= ?", val)
  end

  def self.student_registration_ids_with_count_within_range low, high 
    attendance_count_within_range(low, high).size.keys
  end

  def self.attendance_count_within_range low, high
    attendance_summary.having("count(attended) >= ? and count(attended) < ? ", low, high)
  end

  def self.student_registration_ids_with_count_less_than val
    attendance_count_less_than(val).size.keys
  end

  def self.attendance_count_less_than val
    attendance_summary.having("count(attended) < ?", val)
  end

  def self.student_registration_ids_with_count_greater_than val
    attendance_count_greater_than(val).size.keys
  end

  def self.attendance_count_greater_than val
    attendance_summary.having("count(attended) > ?", val)
  end

  def name
    student.name
  end

  def date
    attendance_sheet.session_date
  end 

  def first_name
    student.first_name
  end

  def last_name
    student.last_name
  end

  def arrival_time_local
     updated_at.localtime
  end

  def thumbnail

    photo_url = student.photo.attached? ? student.photo.variant(resize: "64x64") : nil
    photo_url ?  Rails.application.routes.url_helpers.rails_representation_url(photo_url, only_path: true) : nil
  end

  def group_id
     return group.try(:id).nil? ? -1 : group.id
  end

  def late?
    arrival_time_local.hour >= 10
  end

  def as_json options
    super({methods: [:name, :thumbnail], only: [:id, :name, :attended]})
  end
end
