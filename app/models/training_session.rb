# frozen_string_literal: true

class TrainingSession < ApplicationRecord
  belongs_to :training
  belongs_to :user
  belongs_to :space
  has_many :certifications, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_and_belongs_to_many :users, uniq: true
  belongs_to :course_name

  validates :training, presence: { message: "A training subject is required" }
  validates :user, presence: { message: "A trainer is required" }
  validates :level, presence: { message: "A level is required" }
  validate :is_staff
  before_save :check_course
  scope :between_dates_picked,
        ->(start_date, end_date) {
          where("created_at BETWEEN ? AND ? ", start_date, end_date)
        }
  default_scope -> { order(updated_at: :desc) }

  def is_staff
    errors.add(:string, "user must be staff") unless user.staff?
  end

  def completed?
    certifications.any?
  end

  def levels
    %w[Beginner Intermediate Advanced]
  end

  def self.return_levels
    %w[Beginner Intermediate Advanced]
  end

  def self.filter_by_attribute(value)
    if value
      if value == "search="
        default_scoped
      else
        value = value.split("=").last.gsub("+", " ").gsub("%20", " ")
        joins(:user).where(
          "LOWER(trainings.name) like LOWER(?) OR
                 LOWER(users.name) like LOWER(?) OR
                 CAST(to_char(training_sessions.created_at, 'HH:MI mon DD YYYY') AS text) LIKE LOWER(?) OR
                 LOWER(training_sessions.course) like LOWER(?)",
          "%#{value}%",
          "%#{value}%",
          "%#{value}%",
          "%#{value}%"
        )
      end
    else
      default_scoped
    end
  end

  private

  def check_course
    self.course = nil if course == "no course"
  end
end
