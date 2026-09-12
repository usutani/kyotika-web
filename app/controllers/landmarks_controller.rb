class LandmarksController < ApplicationController
  before_action :set_landmark, only: %i[edit update destroy]
  before_action :set_creators, only: %i[new create edit update]

  def index
    @page_title = "一覧"
    @regions = Region.order(:hiragana)
    @region_id = params[:region_id].presence
    @region_id = nil unless @regions.exists?(@region_id)
    scope = landmark_scope.includes(:creator, :region).order(:hiragana)
    scope = scope.where(region_id: @region_id) if @region_id
    @landmarks = scope
  end

  def new
    @page_title = "追加"
    @landmark = Landmark.new
  end

  def create
    @landmark = Landmark.new(landmark_params)
    @landmark.creator ||= Current.user

    if @landmark.save
      redirect_to landmarks_path, notice: "ランドマークを追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @page_title = "編集"
  end

  def update
    if @landmark.update(landmark_params)
      redirect_to landmarks_path, notice: "ランドマークを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @landmark.destroy
    redirect_to landmarks_path, notice: "ランドマークを削除しました"
  end

  private
    def landmark_scope
      Current.user.administrator? ? Landmark.all : Current.user.created_landmarks
    end

    def set_landmark
      @landmark = landmark_scope.find(params[:id])
    end

    def set_creators
      @creators = User.active.ordered if Current.user&.administrator?
    end

    def landmark_params
      permitted = %i[name latitude longitude url question answer1 answer2 answer3 correct hiragana region_id]
      permitted << :creator_id if Current.user.administrator?
      params.require(:landmark).permit(*permitted, tag_ids: [])
    end
end
