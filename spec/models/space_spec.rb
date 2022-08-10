require "rails_helper"

RSpec.describe Space, type: :model do
  describe "Association" do
    context "has_and_belongs_to_many" do
      it { should have_and_belong_to_many(:trainings) }
    end

    context "has_many" do
      it { should have_many(:pi_readers) }
      it { should have_many(:lab_sessions) }
      it { should have_many(:users) }
      it { should have_many(:training_sessions) }
      it { should have_many(:certifications) }
      it { should have_many(:volunteer_tasks) }
      it { should have_many(:popular_hours) }
      it { should have_many(:shadowing_hours) }
      it { should have_many(:users) }
    end
  end

  describe "validation" do
    context "name" do
      it do
        should validate_presence_of(:name).with_message(
                 "A name is required for the space"
               )
      end
      it do
        should validate_uniqueness_of(:name).with_message(
                 "Space already exists"
               )
      end
    end
  end

  describe "methods" do
    context "#signed_in_users" do
      it "should show the signed in users" do
        user = create(:user, :regular_user)
        space = create(:space)
        LabSession.create(
          user_id: user.id,
          space_id: space.id,
          sign_in_time: 1.hour.ago,
          sign_out_time: DateTime.now.tomorrow
        )
        expect(Space.last.signed_in_users.first).to eq(User.find(user.id))
      end
    end

    context "#recently_signed_out_users" do
      it "should get the recently signed out users" do
        user = create(:user, :regular_user)
        space = create(:space)
        LabSession.create(
          user_id: user.id,
          space_id: space.id,
          sign_in_time: 1.day.ago,
          sign_out_time: 1.hour.ago
        )
        expect(Space.last.recently_signed_out_users.first).to eq(
          User.find(user.id)
        )
      end
    end

    context "#after_create :create_popular_hours" do
      it "should create popular hours after creating space" do
        expect { create(:space) }.to change(PopularHour, :count).by(168)
      end
    end

    context "#makerspace?" do
      it "should return false" do
        space = create(:space, name: "MTC")
        expect(space.makerspace?).to eq(false)
      end

      it "should return true" do
        space = create(:space, name: "Makerspace")
        expect(space.makerspace?).to eq(true)
      end
    end

    context "#ceed?" do
      it "should return false" do
        space = create(:space, name: "MTC")
        expect(space.ceed?).to eq(false)
      end

      it "should return true" do
        space = create(:space, name: "CEED")
        expect(space.ceed?).to eq(true)
      end
    end
  end
end
