class AnswersController < ApplicationController
  def create
    question_ids = session[:quiz_question_ids]
    redirect_to quiz_path and return unless question_ids

    landmark = Landmark.find(params[:landmark_id])
    selected = params[:selected].to_i
    correct = selected == landmark.correct

    session[:quiz_score] += 1 if correct
    session[:quiz_answers] << {
      landmark_id: landmark.id,
      landmark_name: landmark.name,
      selected: selected,
      correct_answer: landmark.correct,
      correct?: correct
    }
    session[:quiz_index] += 1

    @landmark = landmark
    @selected = selected
    @correct = correct
    @index = session[:quiz_index]
    @total = question_ids.size
    @score = session[:quiz_score]
    @last_question = session[:quiz_index] >= @total

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to question_quiz_path }
    end
  end
end
