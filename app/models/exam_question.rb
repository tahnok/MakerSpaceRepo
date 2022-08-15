class ExamQuestion < ApplicationRecord
  belongs_to :exam
  belongs_to :question
  has_one :exam_response
  has_one :user, through: :exam

  def self.create_exam_questions(exam_id, training_id, n_questions, level)
    random_questions =
      Training
        .find(training_id)
        .questions
        .where(level: level)
        .random_records(n_questions)
    random_questions.each do |rq|
      ExamQuestion.create(exam_id: exam_id, question_id: rq.id)
    end
  end
end
