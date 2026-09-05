class MapQuizzesController < ApplicationController
  # 地図探索クイズの初期中心 (京都市街のランドマーク分布の概ね中央)
  INITIAL_CENTER = [ 35.007, 135.752 ].freeze
  INITIAL_ZOOM = 13

  def show
    target_ids = Array(session[:map_quiz_target_ids])
    redirect_to quiz_path and return if target_ids.empty?

    spots = Landmark.where.not(latitude: nil, longitude: nil).pluck(:id, :latitude, :longitude)
    @page_title = "地図クイズ"
    @spots = spots.filter_map do |id, latitude, longitude|
      { id:, latitude:, longitude: } if target_ids.include?(id)
    end
    @found_ids = Array(session[:map_quiz_found_ids]) & target_ids
    @total = target_ids.size
  end

  def create
    if Rails.env.development? && params[:map_landmark_ids].present?
      valid_ids = Landmark.where.not(latitude: nil, longitude: nil).pluck(:id)
      all_ids = params[:map_landmark_ids].split(",").map(&:strip).map(&:to_i).select do |id|
        valid_ids.include?(id)
      end
    else
      all_ids = Landmark.where.not(latitude: nil, longitude: nil).pluck(:id).shuffle
    end
    redirect_to quiz_path and return if all_ids.empty?

    count = params[:map_count].to_i.clamp(1, all_ids.size)
    session[:map_quiz_target_ids] = all_ids.first(count)
    session.delete(:map_quiz_found_ids)

    redirect_to map_quiz_path
  end

  def destroy
    clear_map_quiz_session

    redirect_to quiz_path
  end

  private

  def clear_map_quiz_session
    session.delete(:map_quiz_target_ids)
    session.delete(:map_quiz_found_ids)
  end
end
