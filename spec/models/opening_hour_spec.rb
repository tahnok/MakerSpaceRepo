require "rails_helper"

RSpec.describe OpeningHour, type: :model do
  describe "Association" do
    context "belongs_to" do
      it { should belong_to(:contact_info).without_validating_presence }
    end
  end
end
