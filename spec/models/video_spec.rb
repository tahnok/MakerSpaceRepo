require 'rails_helper'

RSpec.describe Video, type: :model do
  describe 'Association' do
    context 'belongs_to' do
      it { should belong_to(:proficient_project) }
    end

    context 'has_one_attached' do
      it "has video attached" do
        video = create(:video, :with_video)
        expect(video.video).to be_attached
      end

      it 'invalid image attached' do
        video = build(:video, :with_invalid_video)
        expect(video.valid?).to be_falsey
      end
    end
  end

  describe 'Scopes' do
    before(:each) do
      3.times{ create(:video, processed: true) }
      4.times{ create(:video) }
    end

    context '#processed' do
      it 'should return processed videos' do
        expect(Video.processed.count).to eq(3)
      end
    end
  end

  # describe 'Methods' do
  #   context '#response_for_exam' do
  #     it "should return exam_response's exam" do
  #       3.times { create(:exam_with_exam_questions_and_exam_responses) }
  #       exam = Exam.first
  #       question = exam.questions.first
  #       exam_response = question.exam_questions.find_by(exam: exam).exam_response
  #       expect(question.response_for_exam(exam)).to eq(exam_response)
  #     end
  #   end
  # end
end
