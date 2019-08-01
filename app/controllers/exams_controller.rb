class ExamsController < ApplicationController
  before_action :current_user
  before_action :set_exam
  before_action :grant_access, only: [:show]

  def index
    @exams = Exam.all.order(category: :desc).paginate(:page => params[:page], :per_page => 50)
  end

  def new
    @new_exam = Exam.new
    @categories = Question::CATEGORIES
  end

  def create
    @new_exam = current_user.exams.new(exam_params)
    @new_exam.save!
    ExamQuestion.create_exam_questions(@new_exam.id, @new_exam.category, 3)
    if @new_exam.save!
      redirect_to exams_path
      flash[:notice] = "You've successfully created a new exam!"
    end
  end

  def show
    # TODO: Fix the logic in show.html. Too much logic.
    @exam = Exam.find(params[:id])
    @questions = @exam.questions
    @question_responses = @exam.question_responses.where(user_id: current_user.id)
  end

  def destroy
    exam = Exam.find(params[:id])
    if exam.destroy
      flash[:notice] = "Exam Deleted"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to exams_path
  end

  private

  def set_exam
    @exam = Exam.find_by(id: params[:id]) || Exam.new
  end

  def grant_access
    unless @exam.user.eql?(current_user)
      flash[:alert] = "You cannot access this area."
      redirect_to root_path
    end
  end

  def exam_params
    params.require(:exam).permit(:category)
  end
end
