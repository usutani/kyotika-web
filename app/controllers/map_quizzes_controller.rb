class MapQuizzesController < ApplicationController
  # 地図探索クイズの初期中心 (京都市街のランドマーク分布の概ね中央)
  INITIAL_CENTER = [ 35.007, 135.752 ].freeze
  INITIAL_ZOOM = 13

  def show
    @page_title = "地図クイズ"
    spots = Landmark.where.not(latitude: nil, longitude: nil).pluck(:id, :latitude, :longitude)
    @spots = spots.map { |id, latitude, longitude| { id:, latitude:, longitude: } }
    @found_ids = Array(session[:map_quiz_found_ids])
    @total = @spots.size
  end

  def destroy
    session.delete(:map_quiz_found_ids)

    redirect_to map_quiz_path
  end
end
