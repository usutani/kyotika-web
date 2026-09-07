class Quiz::AnswersController < ApplicationController
  allow_unauthenticated_access

  def create
    question_ids = session[:quiz_question_ids]
    redirect_to quiz_path and return unless question_ids

    quiz_index = session[:quiz_index] || 0
    redirect_to quiz_result_path and return if quiz_index >= question_ids.size

    landmark = Landmark.find_by(id: params[:landmark_id])
    selected = params[:selected].to_i
    unless landmark&.id == question_ids[quiz_index] && (1..3).cover?(selected)
      redirect_to quiz_question_path and return
    end

    correct = selected == landmark.correct

    session[:quiz_score] = (session[:quiz_score] || 0) + 1 if correct
    session[:quiz_answers] = (session[:quiz_answers] || []) << {
      landmark_id: landmark.id,
      selected: selected
    }
    session[:quiz_index] = quiz_index + 1

    @landmark = landmark
    @selected = selected
    @correct = correct
    @index = session[:quiz_index]
    @total = question_ids.size
    @score = session[:quiz_score]
    @last_question = session[:quiz_index] >= @total

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to quiz_question_path }
    end
  end
end
