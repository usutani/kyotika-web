class MapQuiz::ResultsController < ApplicationController
  def show
    @page_title = "地図クイズ結果"
    target_ids = Array(session[:map_quiz_target_ids])
    redirect_to quiz_path and return if target_ids.empty?

    found_ids = Array(session[:map_quiz_found_ids]) & target_ids
    @score = found_ids.size
    @total = target_ids.size

    hidden_ids = revealed? ? [] : Array(session[:map_quiz_hidden_ids]) & target_ids
    landmarks = Landmark.where(id: target_ids).index_by(&:id)

    @spots = target_ids.map do |id|
      landmark = landmarks[id]
      found = found_ids.include?(id)
      {
        landmark_id: id,
        name: (found || !hidden_ids.include?(id)) ? landmark&.name : "？？？",
        latitude: landmark&.latitude,
        longitude: landmark&.longitude,
        found?: found,
        hidden?: !found && hidden_ids.include?(id)
      }
    end
  end

  private

  def revealed?
    session[:map_quiz_revealed].present?
  end
end
