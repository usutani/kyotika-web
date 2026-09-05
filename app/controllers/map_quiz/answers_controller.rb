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
    target_ids = Array(session[:map_quiz_target_ids])
    session_ids = Array(session[:map_quiz_found_ids])
    found_ids = target_ids.present? ? session_ids & target_ids : session_ids
    hidden_ids = Array(session[:map_quiz_hidden_ids]) & target_ids
    @found_count = found_ids.size
    @total = target_ids.presence&.size ||
      Landmark.where.not(latitude: nil, longitude: nil).count
    @revealed_now = @correct && session[:map_quiz_revealed].blank? &&
      hidden_ids.present? && found_ids.size >= (target_ids.size / 2.0).ceil
    session[:map_quiz_revealed] = true if @revealed_now
    @complete = Array(session[:map_quiz_target_ids]).present? &&
      (Array(session[:map_quiz_found_ids]) & session[:map_quiz_target_ids]).size >= session[:map_quiz_target_ids].size

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to map_quiz_path }
    end
  end
end
