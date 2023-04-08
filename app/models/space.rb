# frozen_string_literal: true

class Space < ApplicationRecord
  has_many :pi_readers
  has_many :lab_sessions, dependent: :destroy
  has_many :users, through: :lab_sessions
  has_and_belongs_to_many :trainings
  has_many :training_sessions, dependent: :destroy
  has_many :certifications, through: :training_sessions
  has_many :volunteer_tasks, dependent: :destroy
  has_many :popular_hours, dependent: :destroy
  has_many :shadowing_hours
  has_many :users
  has_many :staff_spaces
  has_many :space_staff_hour
  has_many :shifts, dependent: :destroy
  has_many :sub_spaces, dependent: :destroy
  has_many :staff_needed_calendars, dependent: :destroy

  after_create :create_popular_hours

  validates :name,
            presence: {
              message: "A name is required for the space"
            },
            uniqueness: {
              message: "Space already exists"
            }

  def signed_in_users
    lab_sessions
      .where("sign_out_time > ?", Time.zone.now)
      .order(sign_out_time: :desc)
      .map(&:user)
      .uniq
  end

  def recently_signed_out_users
    users =
      lab_sessions
        .includes(:user)
        .where("sign_out_time < ?", Time.zone.now)
        .where.not(user: signed_in_users)
        .order(sign_out_time: :asc)
        .last(20)
        .map(&:user)
        .uniq

    users =
      users
        .sort_by do |user|
          user.lab_sessions.where(space: self).last.sign_out_time
        end
        .reverse
    users
  end

  def create_popular_hours
    (0..6).each do |weekday|
      (0..23).each do |hour|
        PopularHour.find_or_create_by(
          space_id: self.id,
          hour: hour,
          day: weekday
        )
      end
    end
  end

  def makerspace?
    name.eql?("Makerspace")
  end

  def ceed?
    name.eql?("CEED")
  end
end
