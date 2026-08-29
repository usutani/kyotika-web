class QuizzesController < ApplicationController
  def show
    @total = Landmark.count
  end

  def create
    question_ids = Landmark.pluck(:id).shuffle
    session[:quiz_question_ids] = question_ids
    session[:quiz_index] = 0
    session[:quiz_score] = 0
    session[:quiz_answers] = []

    redirect_to quiz_question_path
  end

  def destroy
    session.delete(:quiz_question_ids)
    session.delete(:quiz_index)
    session.delete(:quiz_score)
    session.delete(:quiz_answers)

    redirect_to quiz_path
  end
end
