# frozen_string_literal: true

class ProficientProjectsController < DevelopmentProgramsController
  before_action :only_admin_access,                             only: %i[new create edit update destroy requests]
  before_action :set_proficient_project,                        only: %i[show destroy edit update complete_project]
  before_action :grant_access_to_project,                       only: [:show]
  before_action :set_training_categories, :set_badge_templates, only: %i[new edit]
  before_action :set_files_photos_videos,                       only: %i[show edit]

  def index
    @skills = Skill.all
    @proficient_projects_awarded = Proc.new{ |training| training.proficient_projects.where(id: current_user.order_items.awarded.pluck(:proficient_project_id)) }
    @all_proficient_projects = Proc.new{ |training| training.proficient_projects }
    @advanced_pp_count = Proc.new{ |training| training.proficient_projects.where(level: 'Advanced').count }
    @order_item = current_order.order_items.new
    @user_order_items = current_user.order_items.completed_order
  end

  def requests
    @order_item_waiting_for_approval = OrderItem.all.waiting_for_approval
  end

  def new
    @proficient_project = ProficientProject.new
    @training_levels ||= TrainingSession.return_levels
  end

  def show
    @project_requirements = @proficient_project.project_requirements
    @inverse_required_projects = @proficient_project.inverse_required_projects
    @proficient_projects_selected = ProficientProject
                                        .where.not(id: @project_requirements.pluck(:required_project_id) << @proficient_project.id)
                                        .order(title: :asc)
    @valid_urls = @proficient_project.extract_valid_urls
  end

  def create
    @proficient_project = ProficientProject.new(proficient_project_params)
    if @proficient_project.save
      if params[:badge_requirements_id].present?
        @proficient_project.create_badge_requirements(params[:badge_requirements_id])
      end
      create_photos
      create_files
      flash[:notice] = 'Proficient Project successfully created.'
      render json: {redirect_uri: proficient_project_path(@proficient_project.id).to_s}
    else
      flash[:alert] = 'Something went wrong'
      render json: @proficient_project.errors['title'].first, status: :unprocessable_entity
    end
  end

  def destroy
    @proficient_project.destroy
    respond_to do |format|
      format.html { redirect_to proficient_projects_path, notice: 'Proficient Project has been successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def edit
    @training_levels = TrainingSession.return_levels
  end

  def update
    @proficient_project.delete_all_badge_requirements
    if params[:badge_requirements_id].present?
      @proficient_project.create_badge_requirements(params[:badge_requirements_id])
    end

    if @proficient_project.update(proficient_project_params)
      update_photos
      update_files
      update_videos
      flash[:notice] = 'Proficient Project successfully updated.'
      render json: {redirect_uri: proficient_project_path(@proficient_project.id).to_s}
    else
      flash[:alert] = 'Unable to apply the changes.'
      render json: @proficient_project.errors['title'].first, status: :unprocessable_entity
    end
  end

  def open_modal
    @proficient_project_modal = ProficientProject.find(params[:id])
    @order_item = current_order.order_items.new
    @user_order_items = current_user.order_items.completed_order
    respond_to do |format|
      format.js
    end
  end

  def complete_project
    order_items = current_user.order_items.where(proficient_project_id: @proficient_project.id)
    if order_items.present?
      order_items.first.update(status: 'Waiting for approval')
      flash[:notice] = 'Congratulations on completing this proficient project! The proficient project will now be reviewed by an admin in around 5 business days.'
    else
      flash[:alert] = "This project hasn't been found."
    end
    redirect_to @proficient_project
  end

  def approve_project
    order_item = OrderItem.find_by(id: params[:oi_id])
    if order_item
      space = Space.find_by_name('Makerepo')
      admin = User.find_by_email("avend029@uottawa.ca") || User.where(role: 'admin').last
      course_name = CourseName.find_by_name('no course')
      training_session = TrainingSession.create(training_id: order_item.proficient_project.training_id,
                                                level: order_item.proficient_project.level,
                                                user: admin,
                                                space: space,
                                                course_name: course_name)
      if training_session.present?
        Certification.create(training_session_id: training_session.id, user_id: order_item.order.user_id)
        order_item.update(status: 'Awarded')
        flash[:notice] = 'The project has been approved!'
      else
        flash[:error] = 'An error has occurred, please try again later.'
      end
    else
      flash[:error] = 'An error has occured, please try again later.'
    end
    redirect_to requests_proficient_projects_path
  end

  def revoke_project
    order_item = OrderItem.find_by(id: params[:oi_id])
    if order_item
      order_item.update(status: 'Revoked')
      flash[:alert_yellow] = 'The project has been revoked.'
    else
      flash[:error] = 'An error has occured, please try again later.'
    end
    redirect_to requests_proficient_projects_path
  end

  private

    def grant_access_to_project
      if current_user.order_items.completed_order.where(proficient_project: @proficient_project, status: ['Awarded', 'In progress', 'Waiting for approval']).blank?
        unless current_user.admin? || current_user.staff?
          redirect_to development_programs_path
          flash[:alert] = 'You cannot access this area.'
        end
      end
    end

    def only_admin_access
      unless current_user.admin?
        redirect_to development_programs_path
        flash[:alert] = 'Only admin members can access this area.'
      end
    end

    def proficient_project_params
      params.require(:proficient_project).permit(:title, :description, :training_id, :level, :proficient, :cc, :badge_template_id, :has_project_kit)
    end

    def create_photos
      if params['images'].present?
        params['images'].each do |img|
          dimension = FastImage.size(img.tempfile)
          Photo.create(image: img, proficient_project_id: @proficient_project.id, width: dimension.first, height: dimension.last)
        end
      end
    end

    def create_files
      if params['files'].present?
        params['files'].each do |f|
          @repo = RepoFile.new(file: f, proficient_project_id: @proficient_project.id)
          unless @repo.save
            flash[:alert] = 'Make sure you only upload PDFs for the project files'
          end
        end
      end
    end

    def set_proficient_project
      @proficient_project = ProficientProject.find(params[:id])
    end

    def set_training_categories
      @training_categories = Training.all.order(:name).pluck(:name, :id)
    end

    def set_files_photos_videos
      @photos = @proficient_project.photos || []
      @files = @proficient_project.repo_files.order(created_at: :asc)
      @videos = @proficient_project.videos.processed.order(created_at: :asc)
    end

    def update_photos
      if params['deleteimages'].present?
        @proficient_project.photos.each do |img|
          if params['deleteimages'].include?(img.image.filename.to_s) # checks if the file should be deleted
            img.image.purge
            img.destroy
          end
        end
      end

      if params['images'].present?
        params['images'].each do |img|
          dimension = FastImage.size(img.tempfile)
          Photo.create(image: img, proficient_project_id: @proficient_project.id, width: dimension.first, height: dimension.last)
        end
      end
    end

    def update_files
      if params['deletefiles'].present?
        @proficient_project.repo_files.each do |f|
          if params['deletefiles'].include?(f.file.filename.to_s) # checks if the file should be deleted
            f.file.purge
            f.destroy
          end
        end
      end

      if params['files'].present?

        params['files'].each do |f|
          repo = RepoFile.new(file: f, proficient_project_id: @proficient_project.id)
          unless repo.save
            flash[:alert] = 'Make sure you only upload PDFs for the project files, the PDFs were uploaded'
          end
        end

      end
    end

    def update_videos
      if params['deletevideos'].present?
        @proficient_project.videos.each do |f|
          if params['deletevideos'].include?(f.video_file_name)
            f.video.purge
            f.destroy
          end
        end
      end
    end

    def get_filter_params
      params.permit(:search, :level, :category, :my_projects, :price)
    end

    def set_badge_templates
      @badge_templates = BadgeTemplate.all.order(badge_name: :asc)
    end
end
