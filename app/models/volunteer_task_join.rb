# frozen_string_literal: true

class VolunteerTaskJoin < ApplicationRecord
  belongs_to :volunteer_task, optional: true
  belongs_to :user, optional: true

  # validates_uniqueness_of :user_id, scope: :volunteer_task_id

  scope :active, -> { where(active: true) }
  scope :not_active, -> { where(active: false) }
  scope :user_type_volunteer, -> { where(user_type: "Volunteer") }
end
