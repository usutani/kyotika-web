class Quiz::QuestionsController < ApplicationController
  allow_unauthenticated_access

  def show
    @page_title = "クイズ問題"
    question_ids = session[:quiz_question_ids]
    redirect_to quiz_path and return if question_ids.blank?

    quiz_index = session[:quiz_index] || 0
    redirect_to quiz_result_path and return if quiz_index >= question_ids.size

    @landmark = Landmark.find_by(id: question_ids[quiz_index])
    redirect_to quiz_path and return unless @landmark

    @index = quiz_index
    @total = question_ids.size
    @score = session[:quiz_score] || 0
  end
end
