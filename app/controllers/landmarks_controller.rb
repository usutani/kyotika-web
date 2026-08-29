class LandmarksController < ApplicationController
  def index
    @landmarks = Landmark.order(:hiragana)
  end

  def edit
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

  def invalid_urls
    @invalid_urls = parse_invalid_urls
    @checked_at = parse_checked_at
  end

  private

  def landmark_params
    params.require(:landmark).permit(:name, :latitude, :longitude, :url, :question, :answer1, :answer2, :answer3, :correct, :author, :hiragana)
  end

  def parse_invalid_urls
    file_path = Rails.root.join("doc", "url_check_results.md")
    return [] unless File.exist?(file_path)

    content = File.read(file_path)
    section = content.match(/## Invalid URLs\n\n\|.*?\n\|---.*?\n((?:\|.*?\n)+)/m)
    return [] unless section

    section[1].scan(/\| (\d+) \| (.+?) \| (.+?) \| (.+?) \|/).map do |id, name, url, status|
      { id: id.to_i, name: name.strip, url: url.strip, status: status.strip }
    end
  end

  def parse_checked_at
    file_path = Rails.root.join("doc", "url_check_results.md")
    return nil unless File.exist?(file_path)

    content = File.read(file_path)
    match = content.match(/実行日: (\d{4}-\d{2}-\d{2})/)
    match ? match[1] : nil
  end
end
