class Question < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :trainings
  has_many :exam_questions
  has_many :exams, through: :exam_questions
  has_many :answers, dependent: :destroy

  has_many :exam_responses, through: :exam_questions do
    def find_by_user(user)
      joins(:exam).where("exams.user_id": user.id)
    end
  end

  def response_for_exam(exam)
    exam_responses.joins(:exam).find_by("exams.id": exam.id)
  end

  accepts_nested_attributes_for :answers
  has_many_attached :image
  validates :image, file_content_type: {
      allow: ['image/jpeg', 'image/png'],
      if: -> {image.attached?},
  }
end
