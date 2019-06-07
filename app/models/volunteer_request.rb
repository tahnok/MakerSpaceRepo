class VolunteerRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :space
  scope :approved, -> {where(:approval => true)}
  scope :rejected, -> {where(:approval => false)}
  scope :not_processed, -> {where(:approval => nil)}
  scope :processed, -> {where(:approval => [false, true])}
end
