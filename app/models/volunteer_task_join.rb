class VolunteerTaskJoin < ActiveRecord::Base
  belongs_to :volunteer_task
  belongs_to :user
end
