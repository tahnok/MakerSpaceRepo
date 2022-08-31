# frozen_string_literal: true

require "test_helper"

class ProjectProposalsControllerTest < ActionController::TestCase
  setup { @project_proposal = project_proposals(:three) }

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_proposal" do
    assert_difference("ProjectProposal.count") do
      post :create,
           params: {
             project_proposal: {
               admin_id: @project_proposal.admin_id,
               approved: @project_proposal.approved,
               description: @project_proposal.description,
               title: @project_proposal.title,
               user_id: @project_proposal.user_id,
               youtube_link: @project_proposal.youtube_link,
               username: @project_proposal.username,
               email: @project_proposal.email,
               client: @project_proposal.client,
               area: @project_proposal.area
             }
           }
    end

    assert_redirected_to project_proposal_path(assigns(:project_proposal))
  end

  test "should show project_proposal" do
    get :show, params: { id: @project_proposal }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @project_proposal }
    assert_response :success
  end

  test "should update project_proposal" do
    patch :update,
          params: {
            id: @project_proposal,
            project_proposal: {
              admin_id: @project_proposal.admin_id,
              approved: @project_proposal.approved,
              description: @project_proposal.description,
              title: @project_proposal.title,
              user_id: @project_proposal.user_id,
              youtube_link: @project_proposal.youtube_link,
              username: @project_proposal.username,
              email: @project_proposal.email,
              client: @project_proposal.client,
              area: @project_proposal.area,
              client_type: @project_proposal.client_type
            }
          }
    assert_redirected_to project_proposal_path(assigns(:project_proposal))
  end

  test "should destroy project_proposal" do
    assert_difference("ProjectProposal.count", -1) do
      delete :destroy, params: { id: @project_proposal }
    end

    assert_redirected_to project_proposals_path
  end
end
