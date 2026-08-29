class Quiz::ResultsController < ApplicationController
  def show
    @answers = session[:quiz_answers] || []
    @score = session[:quiz_score] || 0
    @total = @answers.size

    session.delete(:quiz_question_ids)
    session.delete(:quiz_index)
    session.delete(:quiz_score)
    session.delete(:quiz_answers)
  end
end
