class QuizController < ApplicationController
  def show
    @total = Landmark.count
  end

  def create
    question_ids = Landmark.pluck(:id).shuffle
    session[:quiz_question_ids] = question_ids
    session[:quiz_index] = 0
    session[:quiz_score] = 0
    session[:quiz_answers] = []

    redirect_to question_quiz_path
  end

  def question
    question_ids = session[:quiz_question_ids]
    redirect_to quiz_path and return unless question_ids

    @landmark = Landmark.find(question_ids[session[:quiz_index]])
    @index = session[:quiz_index]
    @total = question_ids.size
    @score = session[:quiz_score]
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

  def destroy
    session.delete(:quiz_question_ids)
    session.delete(:quiz_index)
    session.delete(:quiz_score)
    session.delete(:quiz_answers)

    redirect_to quiz_path
  end
end
