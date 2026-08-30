class QuizzesController < ApplicationController
  def show
    @total = Landmark.count
    @default_count = (params[:count].presence || 3).to_i.clamp(1, @total)
    @landmark_ids = params[:landmark_ids] if Rails.env.development?
  end

  def create
    if Rails.env.development? && params[:landmark_ids].present?
      all_ids = params[:landmark_ids].split(",").map(&:strip).map(&:to_i).select { |id| id > 0 }
    else
      all_ids = Landmark.pluck(:id).shuffle
    end
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
