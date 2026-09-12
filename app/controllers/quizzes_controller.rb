class QuizzesController < ApplicationController
  allow_unauthenticated_access

  def show
    clear_quiz_session
    @page_title = "クイズ"
    @regions = Region.order(:hiragana)
    @region_id = params[:region_id].presence
    @region_id = nil unless @regions.exists?(@region_id)
    scope = @region_id ? Landmark.where(region_id: @region_id) : Landmark.all
    map_scope = scope.where.not(latitude: nil, longitude: nil)
    @total = scope.count
    @default_count = @total.zero? ? 0 : (params[:count].presence || 3).to_i.clamp(1, @total)
    @landmark_ids = params[:landmark_ids] if Rails.env.development?
    @map_total = map_scope.count
    @map_default_count = @map_total.zero? ? 0 : (params[:map_count].presence || @map_total).to_i.clamp(1, @map_total)
    @map_landmark_ids = params[:map_landmark_ids] if Rails.env.development?
    @region_counts = Landmark.group(:region_id).count
    @map_region_counts = Landmark.where.not(latitude: nil, longitude: nil).group(:region_id).count
    @all_total = Landmark.count
    @all_map_total = Landmark.where.not(latitude: nil, longitude: nil).count
  end

  def create
    if Rails.env.development? && params[:landmark_ids].present?
      all_ids = params[:landmark_ids].split(",").map(&:strip).map(&:to_i).select { |id| id > 0 }
    else
      region_scope = params[:region_id].present? ? Landmark.where(region_id: params[:region_id]) : Landmark.all
      all_ids = region_scope.pluck(:id).shuffle
    end
    redirect_to quiz_path and return if all_ids.empty?

    count = params[:count].to_i.clamp(1, all_ids.size)
    session[:quiz_question_ids] = all_ids.first(count)
    session[:quiz_index] = 0
    session[:quiz_score] = 0
    session[:quiz_answers] = []

    redirect_to quiz_question_path
  end

  def destroy
    clear_quiz_session

    redirect_to quiz_path
  end

  private

  def clear_quiz_session
    session.delete(:quiz_question_ids)
    session.delete(:quiz_index)
    session.delete(:quiz_score)
    session.delete(:quiz_answers)
  end
end
