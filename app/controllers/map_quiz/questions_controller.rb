class MapQuiz::QuestionsController < ApplicationController
  def show
    @landmark = Landmark.find_by(id: params[:landmark_id])
    return head :not_found unless @landmark&.latitude && @landmark&.longitude

    render layout: false
  end
end
