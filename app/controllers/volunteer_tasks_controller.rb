# frozen_string_literal: true

class VolunteerTasksController < ApplicationController
  layout "volunteer"
  include VolunteerTasksHelper
  before_action :grant_access, except: %i[show index my_tasks complete_task]
  before_action :volunteer_access, only: %i[show index]

  def index
    @volunteer_tasks =
      VolunteerTask
        .all
        .order(created_at: :desc)
        .paginate(page: params[:page], per_page: 50)
  end

  def new
    @user = current_user
    @new_volunteer_task = VolunteerTask.new
    @tasks_categories ||= %w[Events Projects Supervising Workshops Other]
    @certifications = Training.all
    @spaces = Space.all.order(name: :asc)
  end

  def create
    @volunteer_task = VolunteerTask.new(volunteer_task_params)
    @volunteer_task.user_id = @user.try(:id)
    if @volunteer_task.save!
      if params[:certifications_id].present?
        @volunteer_task.create_certifications(params[:certifications_id])
      end
      add_volunteer_join(@volunteer_task.id)
      remove_volunteer_join(@volunteer_task.id)
      redirect_to volunteer_tasks_path
      flash[:notice] = "You've successfully created a new Volunteer Task"
    end
  end

  def show
    @volunteer_task = VolunteerTask.find(params[:id])
    @new_volunteer_join = VolunteerTaskJoin.new
    @new_required_training = RequireTraining.new
    @required_trainings = @volunteer_task.require_trainings
    trainings_already_added =
      @volunteer_task.require_trainings.pluck(:training_id)
    @trainings =
      Training.where.not(id: trainings_already_added).pluck(:name, :id)
    @trainings_already_added =
      Training.where(id: trainings_already_added).pluck(:name, :id)
    @user_trainings = user_trainings
    @volunteer_task_trainings = volunteer_task_trainings
    @volunteer_task_request =
      @volunteer_task
        .volunteer_task_requests
        .where(user_id: current_user.id)
        .not_processed
        .try(:last)
    if current_user.staff?
      @volunteers =
        User
          .joins(:programs)
          .where(programs: { program_type: Program::VOLUNTEER })
          .where.not(id: @volunteer_task.volunteer_task_joins.pluck(:user_id))
          .pluck(:name, :id)
      @staff =
        User
          .where("users.role = ? OR users.role = ?", "staff", "admin")
          .where.not(id: @volunteer_task.volunteer_task_joins.pluck(:user_id))
          .pluck(:name, :id)
      @volunteers_in_task =
        User
          .joins(:programs)
          .where(
            programs: {
              program_type: Program::VOLUNTEER
            },
            id: @volunteer_task.volunteer_task_joins.pluck(:user_id)
          )
          .pluck(:name, :id)
      @staff_in_task =
        User
          .where("users.role = ? OR users.role = ?", "staff", "admin")
          .where(id: @volunteer_task.volunteer_task_joins.pluck(:user_id))
          .pluck(:name, :id)
    end
  end

  def my_tasks
    @your_volunteer_tasks =
      current_user.get_volunteer_tasks_from_volunteer_joins
  end

  def complete_task
    volunteer_task = VolunteerTask.find(params[:id])
    volunteer_task.update(status: "completed")
    redirect_to my_tasks_volunteer_tasks_path
  end

  def edit
    @volunteer_task = VolunteerTask.find(params[:id])
    @tasks_categories = %w[Events Projects Supervising Workshops Other]
    @certifications = Training.all
    @volunteers_in_task =
      User.joins(:programs).where(
        programs: {
          program_type: Program::VOLUNTEER
        },
        id: @volunteer_task.volunteer_task_joins.pluck(:user_id)
      )
    @staff_in_task =
      User.where("users.role = ? OR users.role = ?", "staff", "admin").where(
        id: @volunteer_task.volunteer_task_joins.pluck(:user_id)
      )
  end

  def update
    volunteer_task = VolunteerTask.find(params[:id])
    volunteer_task.delete_all_certifications
    if params[:certifications_id].present?
      volunteer_task.create_certifications(params[:certifications_id])
    end
    add_volunteer_join(volunteer_task.id)
    remove_volunteer_join(volunteer_task.id)
    if volunteer_task.update(volunteer_task_params)
      flash[:notice] = "Volunteer task updated"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to volunteer_tasks_path
  end

  def destroy
    volunteer_task = VolunteerTask.find(params[:id])
    volunteer_task.delete_all_certifications
    if volunteer_task.destroy
      flash[:notice] = "Volunteer Task Deleted"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to volunteer_tasks_path
  end

  private

  def grant_access
    unless current_user.staff?
      flash[:alert] = "You cannot access this area."
      redirect_to root_path
    end
  end

  def volunteer_access
    if !current_user.staff? && !current_user.volunteer?
      flash[:alert] = "You cannot access this area."
      redirect_to root_path
    end
  end

  def add_volunteer_join(task_id)
    @volunteer_task = VolunteerTask.find(task_id)
    if params[:staff_id].present? && (User.find(params[:staff_id]).staff?)
      @volunteer_task_join =
        VolunteerTaskJoin.new(
          volunteer_task_id: @volunteer_task.id,
          user_id: params[:staff_id]
        )
      if @volunteer_task_join.save
        @volunteer_task_join.update(
          user_type: User.find(params[:staff_id]).role.capitalize
        )
      else
        flash[
          :error
        ] = "The staff could not be added to this task, please try again later."
      end
    end
    if params[:volunteer_id].present?
      @volunteer_task_join =
        VolunteerTaskJoin.new(
          volunteer_task_id: @volunteer_task.id,
          user_id: params[:volunteer_id]
        )
      unless @volunteer_task_join.save
        flash[
          :error
        ] = "The volunteer could not be added to this task, please try again later."
      end
    end
  end

  def remove_volunteer_join(task_id)
    if params[:remove_staff_id].present? &&
         (User.find(params[:remove_staff_id]).staff?)
      @volunteer_join_staff =
        VolunteerTaskJoin.find_by(
          user_id: params[:remove_staff_id],
          volunteer_task_id: task_id
        )
      unless @volunteer_join_staff.destroy
        flash[
          :error
        ] = "The staff could not be delete from this task, please try again later."
      end
    end
    if params[:remove_volunteer_id].present?
      @volunteer_join_volunteer =
        VolunteerTaskJoin.find_by(
          user_id: params[:remove_volunteer_id],
          volunteer_task_id: task_id
        )
      unless @volunteer_join_volunteer.destroy
        flash[
          :error
        ] = "The volunteer could not be delete from this task, please try again later."
      end
    end
  end

  def volunteer_task_params
    params.require(:volunteer_task).permit(
      :title,
      :description,
      :status,
      :space_id,
      :joins,
      :category,
      :cc,
      :hours
    )
  end
end
