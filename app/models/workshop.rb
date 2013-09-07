class Workshop < ActiveRecord::Base
  belongs_to :tutor
  belongs_to :season
  has_many :workshop_enrollments
  has_many :aep_registrations, :through => :workshop_enrollments
  attr_accessible :name, :notes, :tutor_id 

  delegate :name, :to => :tutor, :prefix => true
  scope :current, where(:season_id =>Season.current_season_id)
end