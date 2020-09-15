# frozen_string_literal: true

class VolunteersController < ApplicationController
  layout 'volunteer'
  before_action :current_user
  before_action :grant_access, except: [:join_volunteer_program]
  before_action :grant_access_list, only: [:volunteer_list]
  def index
    @user = current_user
  end

  def emails
    @all_emails = User.where(role: 'volunteer').pluck(:email)
    @active_emails = User.joins(:programs).where(role: 'volunteer').where(programs: {active: true, program_type: Program::VOLUNTEER}).pluck(:email)
    @unactive_emails = User.joins(:programs).where(role: 'volunteer').where(programs: {active: false, program_type: Program::VOLUNTEER}).pluck(:email)
  end

  def volunteer_list
    @active_volunteers = User.joins(:programs).where(role: 'volunteer').where(programs: {active: true, program_type: Program::VOLUNTEER})
    @unactive_volunteers = User.joins(:programs).where(role: 'volunteer').where(programs: {active: false, program_type: Program::VOLUNTEER})
  end

  def join_volunteer_program
    if current_user.staff?
      flash[:notice] = 'You already have access to the Volunteer Area.'
    else
      Program.create(user_id: current_user.id, program_type: Program::VOLUNTEER, active: true)
      current_user.update(role: 'volunteer')
      flash[:notice] = "You've joined the Volunteer Program"
    end
    redirect_to volunteers_path
  end

  def my_stats
    volunteer_task_requests = current_user.volunteer_task_requests
    @processed_volunteer_task_requests = volunteer_task_requests.processed.approved.order(created_at: :desc).paginate(page: params[:page], per_page: 15)
    @certifications = current_user.certifications
    @remaining_trainings = current_user.remaining_trainings
  end

  private

  def grant_access
    unless current_user.volunteer? || current_user.admin? || current_user.staff?
      redirect_to root_path
      flash[:alert] = 'You cannot access this area.'
    end
  end

  def grant_access_list
    unless current_user.admin? || current_user.staff?
      redirect_to root_path
      flash[:alert] = 'You cannot access this area.'
    end
  end
end
