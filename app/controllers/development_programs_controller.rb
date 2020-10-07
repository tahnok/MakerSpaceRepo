# frozen_string_literal: true

class DevelopmentProgramsController < ApplicationController
  layout 'development_program'
  before_action :current_user
  before_action :grant_access, except: [:join_development_program]

  def index; end

  def skills
    @skills = Skill.all
    @certifications = current_user.certifications
    @remaining_trainings = current_user.remaining_trainings
    @proficient_projects_awarded = Proc.new{ |training| training.proficient_projects.where(id: current_user.order_items.awarded.pluck(:proficient_project_id)) }
    @proficient_projects_missing = Proc.new{ |training| training.proficient_projects.where.not(id: current_user.order_items.awarded.pluck(:proficient_project_id)) }

  end

  def join_development_program
    program = Program.new(user_id: current_user.id, program_type: Program::DEV_PROGRAM)
    if program.save!
      flash[:notice] = "You've joined the Development Program"
      redirect_to development_programs_path
    else
      flash[:notice] = 'Something went wrong.'
      redirect_to root_path
    end
  end

  private

  def grant_access
    unless current_user.dev_program? || current_user.admin? || current_user.staff?
      redirect_to root_path
      flash[:alert] = 'You cannot access this area.'
    end
  end
end
