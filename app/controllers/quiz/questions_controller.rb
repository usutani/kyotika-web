class Quiz::QuestionsController < ApplicationController
  def show
    question_ids = session[:quiz_question_ids]
    redirect_to quiz_path and return unless question_ids

    @landmark = Landmark.find(question_ids[session[:quiz_index]])
    @index = session[:quiz_index]
    @total = question_ids.size
    @score = session[:quiz_score]
  end
end
