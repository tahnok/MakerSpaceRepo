class VolunteerHour < ActiveRecord::Base
  belongs_to :user
  belongs_to :volunteer_task
  scope :approved, -> {where(:approval => true)}

  def was_processed?
    if self.approval.nil?
      return false
    else
      return true
    end
  end
end
