require 'rails_helper'

RSpec.describe Admin::ShiftsController, type: :controller do
  before(:all) do
    @admin = create(:user, :admin)
  end

  before(:each) do
    session[:expires_at] = DateTime.tomorrow.end_of_day
    session[:user_id] = @admin.id
  end

  describe 'GET /index' do
    context 'logged as regular user' do
      it 'should return 200' do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        get :index
        expect(response).to redirect_to root_path
      end
    end

    context 'logged as admin' do
      it 'should return 200' do
        Space.find_or_create_by(name: 'Makerspace')
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /get_availabilities" do

    context 'get availabilities' do

      it 'should get all the availabilities from the staffs' do
        sa1 = create(:staff_availability)
        sa2 = create(:staff_availability)
        sa3 = create(:staff_availability)
        space1 =  create(:space)
        space2 = create(:space)

        ss1 = StaffSpace.create(space_id: space1.id, user_id: sa1.user_id)
        ss2 = StaffSpace.create(space_id: space1.id, user_id: sa2.user_id)
        StaffSpace.create(space_id: space2.id, user_id: sa2.user_id)
        StaffSpace.create(space_id: space2.id, user_id: sa3.user_id)

        get :get_availabilities, params: {space_id: space1.id}
        expect(response).to have_http_status(:success)
        expect(response.body).to eq([
                                 {
                                   "title": "#{sa1.user.name} is unavailable",
                                   "id": sa1.id,
                                   "daysOfWeek": [sa1.day],
                                   "startTime": sa1.start_time.strftime("%H:%M"),
                                   "endTime": sa1.end_time.strftime("%H:%M"),
                                   "color": "rgba(#{ss1.color.match(/^#(..)(..)(..)$/).captures.map(&:hex).join(", ")}, 1)"
                                 },
                                 {
                                   "title": "#{sa2.user.name} is unavailable",
                                   "id": sa2.id,
                                   "daysOfWeek": [sa2.day],
                                   "startTime": sa2.start_time.strftime("%H:%M"),
                                   "endTime": sa2.end_time.strftime("%H:%M"),
                                   "color": "rgba(#{ss2.color.match(/^#(..)(..)(..)$/).captures.map(&:hex).join(", ")}, 1)"
                                 },
                               ].to_json)

        get :get_availabilities, params: {space_id: space1.id, transparent: true}
        expect(response).to have_http_status(:success)
        expect(response.body).to eq([
                                      {
                                        "title": "#{sa1.user.name} is unavailable",
                                        "id": sa1.id,
                                        "daysOfWeek": [sa1.day],
                                        "startTime": sa1.start_time.strftime("%H:%M"),
                                        "endTime": sa1.end_time.strftime("%H:%M"),
                                        "color": "rgba(#{ss1.color.match(/^#(..)(..)(..)$/).captures.map(&:hex).join(", ")}, 0.25)"
                                      },
                                      {
                                        "title": "#{sa2.user.name} is unavailable",
                                        "id": sa2.id,
                                        "daysOfWeek": [sa2.day],
                                        "startTime": sa2.start_time.strftime("%H:%M"),
                                        "endTime": sa2.end_time.strftime("%H:%M"),
                                        "color": "rgba(#{ss2.color.match(/^#(..)(..)(..)$/).captures.map(&:hex).join(", ")}, 0.25)"
                                      },
                                    ].to_json)
      end

    end

  end

end