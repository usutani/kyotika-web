class LandmarksController < ApplicationController
  def index
    @page_title = "一覧"
    @landmarks = Landmark.order(:hiragana)
  end

  def edit
    @page_title = "編集"
    @landmark = Landmark.find(params[:id])
  end

  def update
    @landmark = Landmark.find(params[:id])
    if @landmark.update(landmark_params)
      redirect_to landmarks_path, notice: "ランドマークを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def landmark_params
    params.require(:landmark).permit(:name, :latitude, :longitude, :url, :question, :answer1, :answer2, :answer3, :correct, :author, :hiragana, tag_ids: [])
  end
end
