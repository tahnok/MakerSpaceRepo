require 'test_helper'

class StaffDashboardControllerTest < ActionController::TestCase

   test "admins succeed at loading Staff Dashboard" do
     session[:user_id] = users(:olivia).id
     session[:expires_at] = "Sat, 03 Jun 2020 05:01:41 UTC +00:00"
     get :index
     #binding.pry
     assert_response :success
   end

   test "regular users are redirected to home" do
     session[:user_id] = users(:bob).id
     session[:expires_at] = "Sat, 03 Jun 2020 05:01:41 UTC +00:00"
     get :index
     #binding.pry
     assert_redirected_to root_path
   end

end
