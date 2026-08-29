class QuizzesController < ApplicationController
  def show
    @total = Landmark.count
    @default_count = params[:count].to_i.clamp(1, @total)
  end

  def create
    all_ids = Landmark.pluck(:id).shuffle
    count = params[:count].to_i.clamp(1, all_ids.size)
    session[:quiz_question_ids] = all_ids.first(count)
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
