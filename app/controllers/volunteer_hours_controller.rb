# frozen_string_literal: true

class VolunteerHoursController < VolunteersController
  before_action :validate_user_for_editing, only: [:edit]
  before_action :validate_staff_for_request,
                only: %i[volunteer_hour_requests volunteer_hour_per_user]
  include VolunteerHoursHelper

  def index
    @user = current_user
    @user_volunteer_hours =
      VolunteerHour
        .where(user_id: @user.id)
        .order(created_at: :desc)
        .paginate(page: params[:page], per_page: 50)
    @total_hours =
      calculate_hours(@user_volunteer_hours.approved.pluck(:total_time))

    @new_volunteer_hour = VolunteerHour.new
    @volunteer_tasks =
      VolunteerTask
        .joins(:volunteer_task_joins)
        .where("volunteer_task_joins.user_id = ?", current_user.id)
        .order(created_at: :desc)
        .pluck(:title, :id)
  end

  def create
    @volunteer_hour = VolunteerHour.new(volunteer_hour_params)
    @volunteer_hour.user_id = @user.try(:id)
    if @volunteer_hour.save!
      redirect_to volunteer_hours_path
      flash[:notice] = "You've successfully sent your volunteer working hours"
    end
  end

  def edit
    @volunteer_hour = VolunteerHour.find(params[:id])
    @volunteer_tasks =
      VolunteerTask.all.order(created_at: :desc).pluck(:title, :id)
    @hour = @volunteer_hour.total_time.floor
    @minutes = ((@volunteer_hour.total_time % 1) * 60).to_i
  end

  def destroy
    volunteer_hour = VolunteerHour.find(params[:id])
    if (volunteer_hour && !volunteer_hour.was_processed?) || current_user.staff?
      volunteer_hour.destroy
      flash[:notice] = "Volunteer Hour Deleted"
    else
      flash[
        :alert
      ] = "Something went wrong or this volunteer hour was processed."
    end
    define_redirect(current_user.role)
  end

  def update
    volunteer_hour = VolunteerHour.find(params[:id])
    if volunteer_hour.update(volunteer_hour_params)
      flash[:notice] = "Volunteer hour updated"
    else
      flash[:alert] = "Something went wrong"
    end
    define_redirect(current_user.role)
  end

  def volunteer_hour_requests
    @new_volunteer_hour_requests =
      VolunteerHour
        .not_processed
        .order(created_at: :desc)
        .paginate(page: params[:page], per_page: 15)
    @old_volunteer_hour_requests =
      VolunteerHour
        .processed
        .order(created_at: :desc)
        .paginate(page: params[:page], per_page: 15)
    @total_volunteer_hour_requests = @new_volunteer_hour_requests.count
  end

  def update_approval
    volunteer_hour = VolunteerHour.find(params[:id])
    if volunteer_hour.update(approval: params[:approval])
      flash[:notice] = "Volunteer hour updated"
    else
      flash[:alert] = "Something went wrong"
    end
    define_redirect(current_user.role)
  end

  def volunteer_hour_per_user
    total_hours_by_approval = VolunteerHour.group(:approval).sum(:total_time)
    @total_volunteer_hours_requested = VolunteerHour.sum(:total_time)
    @total_volunteer_hour_approved = total_hours_by_approval[true]
    @total_volunteer_hour_rejected = total_hours_by_approval[false]
    @users_with_volunteer_hours =
      User
        .volunteers
        .joins(:volunteer_hours)
        .distinct
        .paginate(page: params[:page], per_page: 15)
    @total_volunteers = User.volunteers.count
  end

  private

  def volunteer_hour_params
    params.require(:volunteer_hour).permit(
      :volunteer_task_id,
      :date_of_task,
      :total_time,
      :approval
    )
  end

  def validate_user_for_editing
    volunteer_hour = VolunteerHour.find(params[:id])
    if (current_user.id != volunteer_hour.user_id) && !current_user.staff?
      flash[:alert] = "You are not authorized to edit this."
      redirect_to volunteer_hours_path
    end
  end

  def validate_staff_for_request
    unless current_user.staff?
      flash[:alert] = "You are not authorized access this area"
      redirect_to volunteer_hours_path
    end
  end
end
