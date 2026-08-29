class QuizController < ApplicationController
  def start
    @total = Landmark.count
  end

  def create
    question_ids = Landmark.pluck(:id).shuffle
    session[:quiz_question_ids] = question_ids
    session[:quiz_index] = 0
    session[:quiz_score] = 0
    session[:quiz_answers] = []

    redirect_to quiz_question_path(question_ids.first)
  end

  def show
    question_ids = session[:quiz_question_ids]
    redirect_to quiz_path and return unless question_ids

    @landmark = Landmark.find(params[:id])
    @index = session[:quiz_index]
    @total = question_ids.size
    @score = session[:quiz_score]
  end

  def answer
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
      format.html { redirect_to quiz_question_path(landmark.id) }
    end
  end

  def result
    @answers = session[:quiz_answers] || []
    @score = session[:quiz_score] || 0
    @total = @answers.size

    session.delete(:quiz_question_ids)
    session.delete(:quiz_index)
    session.delete(:quiz_score)
    session.delete(:quiz_answers)
  end

  def quit
    session.delete(:quiz_question_ids)
    session.delete(:quiz_index)
    session.delete(:quiz_score)
    session.delete(:quiz_answers)

    redirect_to quiz_path
  end
end
