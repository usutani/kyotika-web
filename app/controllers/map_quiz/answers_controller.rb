class MapQuiz::AnswersController < ApplicationController
  def create
    landmark = Landmark.find_by(id: params[:landmark_id])
    selected = params[:selected].to_i
    unless landmark && (1..3).cover?(selected)
      head :unprocessable_entity and return
    end

    @landmark = landmark
    @selected = selected
    @correct = selected == landmark.correct

    if @correct
      session[:map_quiz_found_ids] = Array(session[:map_quiz_found_ids]) | [ landmark.id ]
    end
    @found_count = Array(session[:map_quiz_found_ids]).size
    @total = Array(session[:map_quiz_target_ids]).presence&.size ||
      Landmark.where.not(latitude: nil, longitude: nil).count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to map_quiz_path }
    end
  end
end
