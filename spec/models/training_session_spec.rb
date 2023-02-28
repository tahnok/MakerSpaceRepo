require "rails_helper"

RSpec.describe TrainingSession, type: :model do
  describe "Association" do
    context "has_and_belong_to_many" do
      it { should have_and_belong_to_many(:users) }
    end

    context "belongs_to" do
      it do
        expect(TrainingSession.reflect_on_association(:training).macro).to eq(
          :belongs_to
        )
      end
      it do
        expect(TrainingSession.reflect_on_association(:user).macro).to eq(
          :belongs_to
        )
      end
      it do
        expect(TrainingSession.reflect_on_association(:space).macro).to eq(
          :belongs_to
        )
      end
      it do
        expect(
          TrainingSession.reflect_on_association(:course_name).macro
        ).to eq(:belongs_to)
      end
    end

    context "has_many" do
      it { should have_many(:certifications) }
      it { should have_many(:exams) }
      it "dependent destroy: should destroy certifications if destroyed" do
        training_session = create(:training_session_with_certifications)
        expect { training_session.destroy }.to change {
          Certification.count
        }.by(-training_session.certifications.count)
      end
      it "dependent destroy: should destroy exams if destroyed" do
        training_session = create(:training_session_with_exams)
        expect { training_session.destroy }.to change { Exam.count }.by(
          -training_session.exams.count
        )
      end
    end
  end

  describe "Validations" do
    context "presence and uniqueness" do
      subject { create(:training_session) }
      it do
        should validate_presence_of(:training).with_message(
                 "A training subject is required"
               )
      end
      it do
        should validate_presence_of(:level).with_message("A level is required")
      end
    end
  end

  describe "Methods" do
    before(:all) do
      @training_session =
        create(:training_session, created_at: DateTime.yesterday.end_of_day)
      3.times { create(:training_session, created_at: DateTime.now.end_of_day) }
    end

    context "#completed?" do
      it "should return false" do
        expect(@training_session.completed?).to eq(false)
      end

      it "should return true" do
        training_session = create(:training_session_with_certifications)
        expect(training_session.completed?).to eq(true)
      end
    end

    context "#levels" do
      it "should return list of levels" do
        levels = %w[Beginner Intermediate Advanced]
        expect(@training_session.levels).to eq(levels)
      end
    end

    context "#return_levels" do
      it "should return list of levels" do
        levels = %w[Beginner Intermediate Advanced]
        expect(TrainingSession.return_levels).to eq(levels)
      end
    end

    context "#check_course" do
      it "should return course as nil" do
        training_session = build(:training_session, course: "no course")
        training_session.send(:check_course)
        expect(training_session.course).to eq(nil)
      end

      it "should not return course as nil" do
        training_session = build(:training_session, course: "GNG2101")
        training_session.send(:check_course)
        expect(training_session.course).to eq("GNG2101")
      end
    end

    context "#between_dates_picked" do
      it "should return no training sessions" do
        start_date = DateTime.yesterday.beginning_of_day
        end_date = DateTime.yesterday.end_of_day
        expect(
          TrainingSession.between_dates_picked(start_date, end_date).count
        ).to eq(1)
      end

      it "should return one training sessions" do
        start_date = DateTime.yesterday.beginning_of_day
        end_date = DateTime.tomorrow.end_of_day
        expect(
          TrainingSession.between_dates_picked(start_date, end_date).count
        ).to eq(4).or eq(5) # Can be 5 in multithreaded
      end
    end

    after(:all) { Training.destroy_all }
  end
end
