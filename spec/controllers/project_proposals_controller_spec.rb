require 'rails_helper'

RSpec.describe ProjectProposalsController, type: :controller do

  before :each do
    @admin = create(:user, :admin)
    @regular_user = create(:user, :regular_user)
    session[:user_id] = @regular_user.id
    session[:expires_at] = Time.zone.now + 10000
  end

  before(:all) do
    3.times{ create(:project_proposal, :normal) }
    create(:project_proposal, :approved)
    create(:project_proposal, :joined)
    2.times{ create(:project_proposal, :completed) }
  end

  describe "GET #index" do
    context "index" do
      it 'should get pending project proposals' do
        session[:user_id] = @admin.id
        get :index
        expect(response).to have_http_status(:success)
        expect(@controller.instance_variable_get(:@pending_project_proposals).count).to eq(3)
      end
    end
  end
  
  describe 'GET #show' do
    context "show" do
      it 'should show the project proposal' do
        pp = ProjectProposal.where(approved: 1).first
        get :show, params: {id: pp.id}
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #new' do
    context "new" do
      it 'should show the form for a new project proposal' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #edit' do
    context "edit" do
      it 'should show the form to edit the project proposal' do
        session[:user_id] = @admin.id
        pp = ProjectProposal.first
        get :edit, params: {id: pp.id}
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #projects_assigned" do
    context "projects_assigned" do
      it 'should get the only joined project' do
        get :projects_assigned
        expect(response).to have_http_status(:success)
        expect(@controller.instance_variable_get(:@assigned_project_proposals).count).to eq(1)
      end
    end
  end

  describe "GET #projects_completed" do
    context "projects_completed" do
      it 'should show the only completed project' do
        get :projects_completed
        expect(response).to have_http_status(:success)
        expect(@controller.instance_variable_get(:@completed_project_proposals).count).to eq(2)
      end
    end
  end

  describe "POST #create" do
    context "create" do
      it 'should create a project proposal' do
        project_proposal_params = FactoryBot.attributes_for(:project_proposal, :normal)
        expect { post :create, params: {project_proposal: project_proposal_params} }.to change(ProjectProposal, :count).by(1)
        expect(response).to redirect_to project_proposal_path(ProjectProposal.last)
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(flash[:notice]).to eq('Project proposal was successfully created.')
      end

      it 'should fail creating a project proposal' do
        project_proposal_params = FactoryBot.attributes_for(:project_proposal, :broken)
        expect { post :create, params: {project_proposal: project_proposal_params} }.to change(ProjectProposal, :count).by(0)
        expect(response).to have_http_status(:success)
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

      it 'should create a repository with images and files' do
        project_proposal_params = FactoryBot.attributes_for(:project_proposal, :normal)
        expect { post :create, params: {project_proposal: project_proposal_params, files: [fixture_file_upload(Rails.root.join('spec/support/assets', 'RepoFile1.pdf'), 'application/pdf')], images: [fixture_file_upload(Rails.root.join('spec/support/assets', 'avatar.png'), 'image/png')]} }.to change(ProjectProposal, :count).by(1)
        expect(RepoFile.count).to eq(1)
        expect(Photo.count).to eq(1)
        expect(flash[:notice]).to eq('Project proposal was successfully created.')
      end
    end
  end

  describe 'PATCH #update' do
    context 'Update project proposal' do
      it 'should update the project proposal' do
        project_proposal = ProjectProposal.first
        patch :update, params: {id: project_proposal.id, project_proposal: {title: "abc123"}}
        expect(response).to redirect_to project_proposal_path(project_proposal)
        expect(flash[:notice]).to eq('Project proposal was successfully updated.')
      end

      it 'should update the project proposal' do
        project_proposal = ProjectProposal.first
        patch :update, params: {id: project_proposal.id, project_proposal: {title: "abc$123"}}
        expect(response).to have_http_status(:success)
      end

      it 'should update the project proposal with photos and files' do
        create(:project_proposal, :with_repo_files)
        patch :update, params: {id: ProjectProposal.last.id, project_proposal: {files: [fixture_file_upload(Rails.root.join('spec/support/assets', 'RepoFile1.pdf'), 'application/pdf')], images: [fixture_file_upload(Rails.root.join('spec/support/assets', 'avatar.png'), 'image/png')], deleteimages: [Photo.last.image.filename.to_s], deletefiles: [RepoFile.last.file.id.to_s]}}
        expect(RepoFile.count).to eq(1)
        expect(Photo.count).to eq(1)
        expect(flash[:notice]).to eq('Project proposal was successfully updated.')
      end
    end
  end

  describe 'DELETE #update' do
    context 'Delete project proposal' do
      it 'should delete the project proposal' do
        project_proposal = ProjectProposal.first
        delete :destroy, params: {id: project_proposal.id}
        expect(response).to redirect_to project_proposals_url
        expect(flash[:notice]).to eq('Project proposal was successfully deleted.')
      end
    end

  end

  describe 'POST #approve' do
    context 'Approve project proposal' do
      it 'should approve the project proposal' do
        session[:user_id] = @admin.id
        project_proposal = ProjectProposal.first
        post :approve, params: {id: project_proposal.id}
        expect(response).to redirect_to project_proposal_path(project_proposal.id)
        expect(flash[:notice]).to eq('Project Proposal Approved')
        expect(ProjectProposal.last.approved?).to be_truthy
      end
    end
  end

  describe 'POST #decline' do
    context 'Decline project proposal' do
      it 'should decline the project proposal' do
        session[:user_id] = @admin.id
        project_proposal = ProjectProposal.first
        post :decline, params: {id: project_proposal.id}
        expect(response).to redirect_to project_proposal_path(project_proposal.id)
        expect(flash[:notice]).to eq('Project Proposal Declined')
        expect(project_proposal.approved?).to be_falsey
      end
    end
  end

  describe 'GET #join_project_proposal' do
    context 'Join project proposal' do
      it 'should join the project proposal' do
        project_proposal = ProjectProposal.first
        get :join_project_proposal, params: {project_proposal_id: project_proposal.id}
        expect(response).to redirect_to project_proposal_path(project_proposal.id)
        expect(flash[:notice]).to eq('You joined this project.')
      end

      it 'should not let the user join the project proposal' do
        project_proposal = ProjectProposal.first
        get :join_project_proposal, params: {project_proposal_id: project_proposal.id}
        get :join_project_proposal, params: {project_proposal_id: project_proposal.id}
        expect(response).to redirect_to project_proposal_path(project_proposal.id)
        expect(flash[:alert]).to eq('You already joined this project or something went wrong.')
      end
    end
  end

  describe 'GET #unjoin_project_proposal' do
    context 'Un-join project proposal' do
      it 'should un-join the project proposal' do
        project_proposal = ProjectProposal.first
        get :join_project_proposal, params: {project_proposal_id: project_proposal.id}
        get :unjoin_project_proposal, params: {project_proposal_id: project_proposal.id, project_join_id: ProjectJoin.last.id}
        expect(response).to redirect_to project_proposal_path(project_proposal.id)
        expect(flash[:notice]).to eq('You unjoined this project.')
      end
    end
  end

  describe "GET #user_projects" do
    context "user_projects" do
      it 'should return success' do
        get :user_projects
        expect(response).to have_http_status(:success)
      end
    end
  end

  after :all do
    ProjectProposal.destroy_all
  end
end



