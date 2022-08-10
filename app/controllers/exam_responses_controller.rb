class ExamResponsesController < ApplicationController
  before_action :current_user
  before_action :grant_access

  def create
    permitted_params = exam_response_params
    exam = Exam.find(permitted_params[:exam_id])
    answer = Answer.find(permitted_params[:answer_id])
    question = answer.question
    response = question.response_for_exam(exam)
    if response
      response.update(answer_id: answer.id, correct: answer.correct)
    else
      exam_question_id =
        ExamQuestion.where(exam_id: exam.id, question_id: question.id).last.id
      response =
        ExamResponse.new(
          exam_question_id: exam_question_id,
          answer_id: answer.id,
          correct: answer.correct
        )
      response.save!
    end
    respond_to { |format| format.js { head :no_content } }
  end

  private

  def grant_access
    unless Exam.find(exam_response_params[:exam_id]).user.eql?(current_user)
      flash[:alert] = "Do not try this"
      redirect_to :root
    end
  end

  def exam_response_params
    params.permit(:answer_id, :exam_id, :response_id)
  end
end
