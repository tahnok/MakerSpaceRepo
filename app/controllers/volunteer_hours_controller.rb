class VolunteerHoursController < VolunteersController
  before_action :validate_user_for_editing, only:[:edit]
  include VolunteerHoursHelper

  def index
    @user = current_user
    @user_volunteer_hours = VolunteerHour.where(user_id: @user.id).order(created_at: :desc).paginate(:page => params[:page], :per_page => 50)
    @total_hours = calculate_hours(@user_volunteer_hours.approved.pluck(:total_time))
  end

  def new
    @new_volunteer_hour = VolunteerHour.new
    @volunteer_tasks = VolunteerTask.all.order(created_at: :desc).pluck(:title, :id)
  end

  def create
    @volunteer_hour = VolunteerHour.new(volunteer_hour_params)
    @volunteer_hour.user_id = @user.try(:id)
    if @volunteer_hour.save!
      redirect_to new_volunteer_hour_path
      flash[:notice] = "You've successfully sent your volunteer working hours"
    end
  end

  def edit
    @user = current_user
    @volunteer_hour = VolunteerHour.find(params[:id])
    @volunteer_tasks = VolunteerTask.all.order(created_at: :desc).pluck(:title, :id)
  end

  def destroy
    volunteer_hour = VolunteerHour.find(params[:id])
    if (volunteer_hour && !volunteer_hour.was_processed?) || current_user.staff?
      volunteer_hour.destroy
      flash[:notice] = "Volunteer Hour Deleted"
    elsif
      flash[:alert] = "Something went wrong or this volunteer hour was processed."
    end
    redirect_to volunteer_hours_path
  end

  def update
    flash[:notice] = "passing"
    redirect_to edit_volunteer_hour_path
  end

  private

  def volunteer_hour_params
    params.require(:volunteer_hour).permit(:volunteer_task_id, :date_of_task, :total_time)
  end

  def validate_user_for_editing
    volunteer_hour = VolunteerHour.find(params[:id])
    if (current_user.id != volunteer_hour.user_id) && !current_user.staff?
      flash[:alert] = "You are not authorized to edit this."
      redirect_to volunteer_hours_path
    end
  end
end
