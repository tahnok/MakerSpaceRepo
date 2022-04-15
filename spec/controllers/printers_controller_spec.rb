require 'rails_helper'

RSpec.describe PrintersController, type: :controller do

  describe 'Link printer to user' do

    before(:all) do
      build :printer, :UM2P_01
      build :printer, :UM2P_02
      build :printer, :UM3_01
      build :printer, :RPL2_01
      build :printer, :RPL2_02
      build :printer, :dremel_10_17
    end

    context 'Create a printer session' do

      it 'should create a Printer Session' do
        create :user, :regular_user
        admin = create(:user, :admin)
        session[:user_id] = admin.id
        patch :link_printer_to_user, params: {printer: {user_id: 1, printer_id: 1}}
        expect(flash[:notice]).to eq("Printer Session Created")
        expect(response).to redirect_to staff_printers_printers_path
      end

      it 'should create deny access' do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        patch :link_printer_to_user, params: {printer: {user_id: 1, printer_id: 1}}
        expect(flash[:alert]).to eq("You cannot access this area.")
        expect(response).to redirect_to "/"
      end

      it 'should fail creating the print session' do
        create :user, :regular_user
        admin = create(:user, :admin)
        session[:user_id] = admin.id
        patch :link_printer_to_user, params: {printer: {user_id: 1, printer_id: ""}}
        expect(flash[:alert]).to eq("Please add both printer and user.")
        expect(response).to redirect_to staff_printers_printers_path
      end

    end
  end

  describe 'controllers that have views' do

    before(:each) do
      @um2_1 = create :printer, :UM2P_01
      @um2_2 = create :printer, :UM2P_02
      @um3 = create :printer, :UM3_01
      @rpl1 = create :printer, :RPL2_01
      @rpl2 = create :printer, :RPL2_02
      @dremel = create :printer, :dremel_10_17
    end

    context 'Variable setup for views' do

      it 'should setup all variables for staff_printers_updates' do
        create :user, :regular_user
        admin = create(:user, :admin)
        session[:user_id] = admin.id
        get :staff_printers_updates
        expect(response).to have_http_status(:success)
        expect(@controller.instance_variable_get(:@ultimaker_printer_ids)).to eq([@um2_1.id, @um2_2.id])
        expect(@controller.instance_variable_get(:@ultimaker3_printer_ids)).to eq([@um3.id])
        expect(@controller.instance_variable_get(:@replicator2_printer_ids)).to eq([@rpl1.id, @rpl2.id])
        expect(@controller.instance_variable_get(:@dremel_printer_ids)).to eq([@dremel.id])
      end

      it 'should create all the variables for staff_printers' do
        create :user, :regular_user
        admin = create(:user, :admin)
        session[:user_id] = admin.id
        um2p_session = create(:printer_session, :um2p_session)
        um3_session = create(:printer_session, :um3_session)
        rpl2_session = create(:printer_session, :rpl2_session)
        dremel_session = create(:printer_session, :dremel_session)
        get :staff_printers
        expect(response).to have_http_status(:success)
      end

    end
  end


end