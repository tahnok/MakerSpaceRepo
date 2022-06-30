require 'rails_helper'

RSpec.describe JobOrderStatus, type: :model do
  describe 'Association' do
    context 'belongs_to' do
      it { should belong_to(:job_order) }
      it { should belong_to(:job_status) }
    end
  end
end
