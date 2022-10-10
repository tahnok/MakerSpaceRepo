# frozen_string_literal: true

require "test_helper"

class Staff::TrainingSessionsControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = User.find_by(username: "olivia").id
    session[:expires_at] = "Sat, 03 Jun 2025 05:01:41 UTC +00:00"
    @user = User.find_by(username: "olivia")
    @request.env["HTTP_REFERER"] = staff_training_sessions_url
  end

  test "staff can initiate a new training_session" do
    get :new
    assert_response :ok
  end

  test "staff can create a new training session" do
    post :create,
         params: {
           training_session_users: [users(:bob).id, users(:mary).id],
           training_id: Training.last.id,
           course: "GNG2205",
           level: "Beginner",
           training_session: {
             space_id: Space.last.id
           }
         }
    @new_training_session =
      TrainingSession.where(
        training_id: Training.last.id,
        user_id: @user.id,
        course: "GNG2205",
        space_id: Space.last.id
      ).last
    assert @new_training_session.present?
    assert @new_training_session.users.include? User.find_by(username: "bob")
    assert_redirected_to staff_training_session_path(@new_training_session.id)
  end

  test "staff can change the trainging type by choosing a different training" do
    patch :update,
          params: {
            id: training_sessions(:lathe_1_session),
            changed_params: {
              training_id: trainings(:welding_3)
            }
          }
    assert TrainingSession.find_by(
             training_id: Training.find_by(name: "welding_3"),
             user_id: @user.id
           ).present?
    assert_not TrainingSession.find_by(
                 training_id: Training.find_by(name: "lathe_1"),
                 user_id: @user.id
               ).present?
    assert_redirected_to @request.env["HTTP_REFERER"] # redirect_to :back
    assert_equal flash[:notice], "Training session updated succesfully"
  end

  test "staff can certify users in training session" do
    training_session = training_sessions(:lathe_1_session)
    training_session.users << User.find_by(username: "adam")
    training_session.save
    assert training_session.users.include? User.find_by(username: "adam")
    post :certify_trainees, params: { id: training_session }
    assert_redirected_to staff_dashboard_index_path
    assert Certification.find_by(
             user_id: users(:adam).id,
             training_session_id: training_sessions(:lathe_1_session).id
           ).present?
  end

  test "staff can view their own training sessions" do
    get :show, params: { id: training_sessions(:lathe_1_session) }
    assert_response :ok
  end

  test "staff can't view training sessions owned by other staff or admins" do
    get :show, params: { id: training_sessions(:welding_3_session) }
    assert_redirected_to new_staff_training_session_path
    assert_equal flash[:alert], "Can't access training session"
  end

  test "admin can view any training session" do
    session[:user_id] = User.find_by(username: "adam").id
    session[:expires_at] = "Sat, 03 Jun 2025 05:01:41 UTC +00:00"
    get :show, params: { id: training_sessions(:lathe_1_session) }
    assert_response :ok
  end

  test "staff can delete a training session " do
    delete :destroy, params: { id: training_sessions(:lathe_1_session) }
    assert_not TrainingSession.find_by(
                 training_id: Training.find_by(name: "lathe_1"),
                 user_id: @user.id
               ).present?
    assert_redirected_to staff_dashboard_index_path
    assert_equal flash[:notice], "Deleted Successfully"
  end

  test "removing a user from a training session deletes the associated certification if it exists" do
    session[:user_id] = User.find_by(username: "adam").id
    session[:expires_at] = "Sat, 03 Jun 2025 05:01:41 UTC +00:00"
    training_session = training_sessions(:lathe_1_session)
    training_session.users << User.find_by(username: "olivia")
    training_session.save
    post :certify_trainees, params: { id: training_session }
    assert Certification.find_by(
             user_id: users(:olivia).id,
             training_session_id: training_sessions(:lathe_1_session).id
           ).present?
    patch :update,
          params: {
            dropped_users: ["olivia"],
            id: training_session,
            changed_params: {
              user_id: @user.id
            }
          }
    assert_not Certification.find_by(
                 user_id: users(:olivia).id,
                 training_session_id: training_sessions(:lathe_1_session).id
               ).present?
  end

  test "staff can revoke a certification issued by them at an old training session" do
    training_session = training_sessions(:old_soldering_session)
    cert = certifications(:mary_old_soldering)
    delete :revoke_certification,
           params: {
             id: training_session.id,
             cert_id: cert.id
           }
    assert_equal flash[:notice], "Deleted Successfully"
    assert_not Certification.find_by(id: cert.id).present?
    assert_redirected_to user_path(users(:mary).username)
  end
end
