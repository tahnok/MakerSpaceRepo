class Staff::TrainingSessionsController < StaffDashboardController

  before_action :current_training_session, except: [:new, :create, :index]
  before_action :changed_params, only: [:update]
  before_action :verify_ownership, except: [:new, :create, :index, :renew_certification]

  layout 'staff_area'

  def index

  end

  def new
    @new_training_session = TrainingSession.new
  end

  def create
    @new_training_session = TrainingSession.new(default_params)

    if params['training_session_users'].present?
      params['training_session_users'].each do |user_id|
        @new_training_session.users << User.find(user_id)
      end
    end

    if @new_training_session.save
      redirect_to staff_training_session_path(@new_training_session.id)
    else
      flash[:alert] = "Something went wrong. Please try again."
      redirect_back(fallback_location: root_path)
    end

  end

  def update
    if changed_params['user_id'].present?
      unless @user.admin?
        flash[:alert] = "You're not an admin."
        redirect_back(fallback_location: root_path)
      end
    end

    @current_training_session.update(changed_params)

    if params['dropped_users'].present?
      @current_training_session.users -= User.where(username: params[ 'dropped_users'])
      User.where(username: params[ 'dropped_users']).each do |user|
        cert = user.certifications.find_by(training_session_id: @current_training_session.id)
        if cert.present?
          unless cert.destroy
            flash[:alert] = "Error deleting #{user.username}'s #{@current_training_session.training.name} certification."
          end
        end
      end
    end

    if params['added_users'].present?
      @current_training_session.users +=  User.where(username: params['added_users'])
    end

    @current_training_session.users = @current_training_session.users.uniq

    if @current_training_session.save
      flash[:notice] = "Training session updated succesfully"
    else
      flash[:alert] = "Something went wrong, please try again"
    end

    redirect_back(fallback_location: root_path)
  end

  def certify_trainees
    @current_training_session.users.each do |graduate|
      certification = Certification.new(user_id: graduate.id, training_session_id: @current_training_session.id)
      unless certification.save
       flash[:alert] = "#{graduate.username}'s certification not saved properly!"
      end
    end
    flash[:notice] = "Training Session Completed Successfully"
    redirect_to staff_index_url
  end

  def renew_certification
    cert = Certification.find(params[:cert_id])
    if cert.touch
      flash[:notice] = "Renewed Successfully"
    else
      flash[:alert] = "Something went wrong, try refreshing"
    end
    redirect_to user_path(cert.user.username)
  end

  def revoke_certification
    cert = Certification.find(params[:cert_id])
    if cert.destroy
      flash[:notice] = "Deleted Successfully"
    else
      flash[:alert] = "Something went wrong, try refreshing"
    end
    redirect_to user_path(cert.user.username)
  end

  def destroy
    if @current_training_session.destroy
        flash[:notice] = "Deleted Successfully"
        redirect_to staff_index_url
    else
        flash[:alert] = "Something went wrong"
        redirect_to :back
    end
  end

  def training_report
    respond_to do |format|
      format.html
      format.csv {send_data ReportGenerator.training_session_report(params[:id]) }
    end
  end
  
  private

    def default_params
      if params[:user_id].present?
        if @user.admin?
          return {user_id: params[:user_id], training_id: params[:training_id], course: params[:course]}
        end
      else
        return {user_id: current_user.id, training_id: params[:training_id], course: params[:course]}
      end
    end

    def training_session_params
      params.require(:training_session).permit(:training_id, :course, :users)
    end

    def current_training_session
      @current_training_session = TrainingSession.find(params[:id])
      @staff = User.find(@current_training_session.user_id)
    end

    def changed_params
      params.require(:changed_params).permit(:training_id, :course, :user_id).reject { |_, v| v.blank? }
    end

    def verify_ownership
      unless (@user.admin? || @current_training_session.user == @user)
        flash[:alert] = "Can't access training session"
        redirect_to new_staff_training_session_path
      end
    end

end
