require 'rails_helper'

RSpec.describe Admin::CoursesController, type: :controller do
  before(:all) do
    4.times { create(:course) }
    @admin = create(:user, :admin)
    @course = Course.last
  end

  before(:each) do
    session[:user_id] = @admin.id
  end

  describe "GET /index" do
    context 'logged as admin' do
      it 'should return 200 response' do
        get :index
        expect(response).to have_http_status(:success)
        expect(@controller.instance_variable_get(:@courses).count).to eq(Course.count)
      end
    end

    context 'logged as regular user' do
      it 'should redirect user to root' do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        get :index
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET /new' do
    context 'logged as admin' do
      it 'should return a 200' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /edit" do
    context 'logged as admin' do
      it 'should return 200 response' do
        get :edit, params: {id: @course.id}
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /create' do
    context 'logged as admin' do
      it 'should create a course and redirect' do
        course_params = FactoryBot.attributes_for(:course)
        expect { post :create, params: {course: course_params} }.to change(Course, :count).by(1)
        expect(flash[:notice]).to eq('Course added successfully!')
        expect(response).to redirect_to admin_courses_path
      end
    end
  end

  describe 'PATCH /update' do
    context 'logged as admin' do
      it 'should not update invalid input for course' do
        first_course = Course.first
        patch :update, params: {id: @course.id, course: {name: first_course.name} }
        expect(response).to redirect_to admin_courses_path
        expect(Course.find(@course.id).name).to eq(@course.name)
        expect(flash[:alert]).to eq('Input is invalid')
      end

      it 'should update the course' do
        patch :update, params: {id: @course.id, course: {name: "New Random Name"} }
        expect(response).to redirect_to admin_courses_path
        expect(Course.find(@course.id).name).to eq("New Random Name")
        expect(flash[:notice]).to eq('Course renamed successfully')
      end
    end
  end

  describe "DELETE /destroy" do
    context 'logged as admin' do
      it 'should destroy the course' do
        expect { delete :destroy, params: {id: @course.id} }.to change(Course, :count).by(-1)
        expect(@controller.instance_variable_get(:@changed_course)).to eq(@course)
        expect(response).to redirect_to admin_courses_path
        expect(flash[:notice]).to eq('Course removed successfully')
      end
    end
  end
end


