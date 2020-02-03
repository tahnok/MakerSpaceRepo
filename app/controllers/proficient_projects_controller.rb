class ProficientProjectsController < DevelopmentProgramsController
  before_action :grant_access_to_project, only: [:show]
  before_action :only_staff_access, only: [:new, :create]

  def index
  end

  def new
    @proficient_project = ProficientProject.new
    @training_categories = Training.all.order(:name).pluck(:name, :id)
    @training_levels = TrainingSession.return_levels
  end

  def show
    @proficient_project= ProficientProject.find(params[:id])
    @photos = @proficient_project.photos || []
    @files = @proficient_project.repo_files.order(created_at: :asc)
  end

  def create
    @proficient_project = ProficientProject.new(proficient_project_params)
    if @proficient_project.save
      puts params
      create_photos
      create_files
      flash[:notice] = "Proficient Project successfully created."
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to new_proficient_project_path
  end

  private

  def grant_access_to_project
    unless current_user.dev_program? || current_user.admin? || current_user.staff?
      redirect_to root_path
      flash[:alert] = "You cannot access this area."
    end
  end

  def only_staff_access
    unless current_user.staff?
      redirect_to development_programs_path
      flash[:alert] = "Only staff members can access this area."
    end
  end

  def proficient_project_params
    params.require(:proficient_project).permit(:title, :description, :training_id, :level)
  end

  def create_photos
    params['images'].each do |img|
      dimension = FastImage.size(img.tempfile)
      Photo.create(image: img, proficient_project_id: @proficient_project.id, width: dimension.first, height: dimension.last)
    end if params['images'].present?
  end

  def create_files
    params['files'].each do |f|
      RepoFile.create(file: f, proficient_project_id: @proficient_project.id)
    end if params['files'].present?
  end

end
