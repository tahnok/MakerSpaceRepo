require "rails_helper"

RSpec.describe Question, type: :model do
  describe "Association" do
    context "belongs_to" do
      it { should belong_to(:user) }
    end

    context "has_and_belong_to_many" do
      it { should have_and_belong_to_many(:trainings) }
    end

    context "has_many" do
      it { should have_many(:exam_questions) }
      it { should have_many(:exams) }
      it { should have_many(:answers) }
      it "dependent destroy: should destroy upvotes if destroyed" do
        question = create(:question_with_answers)
        expect { question.destroy }.to change { Answer.count }.by(
          -question.answers.count
        )
      end
      it { should have_many(:exam_responses) }
    end

    context "accepts_nested_attributes_for" do
      it { should accept_nested_attributes_for(:answers) }
    end

    context "has_one_attached" do
      it "has image attached" do
        question = create(:question, :with_image)
        expect(question.images).to be_attached
      end

      it "invalid image attached" do
        question = build(:question, :with_invalid_image)
        expect(question.valid?).to be_falsey
      end
    end
  end

  describe "Methods" do
    context "#response_for_exam" do
      it "should return exam_response's exam" do
        3.times { create(:exam_with_exam_questions_and_exam_responses) }
        exam = Exam.first
        question = exam.questions.first
        exam_response =
          question.exam_questions.find_by(exam: exam).exam_response
        # expect(question.response_for_exam(exam)).to eq(exam_response)
      end
    end
  end
end
