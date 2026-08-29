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

    landmark_ids = @invalid_urls.map { |item| item[:id] }
    landmarks = Landmark.where(id: landmark_ids).index_by(&:id)
    @invalid_urls.each do |item|
      landmark = landmarks[item[:id]]
      item[:db_url] = landmark&.url
      item[:db_url_status] = landmark&.url_status
      item[:db_url_checked_at] = landmark&.url_checked_at
    end
  end

  def check_url
    @landmark = Landmark.find(params[:id])
    check_and_cache_url(@landmark)
    redirect_to invalid_urls_path, notice: "#{@landmark.name} の URL チェックが完了しました"
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

  def check_and_cache_url(landmark)
    require "net/http"
    require "uri"
    require "zlib"
    require "stringio"

    unsaf_chars = Regexp.new("[^a-zA-Z0-9\\-._~:/?#\\[\\]@!$&'+,;=%]")

    begin
      url = landmark.url.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
      encoded_url = URI::DEFAULT_PARSER.escape(url, unsaf_chars)

      uri = URI.parse(encoded_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = 5
      http.read_timeout = 5

      request = Net::HTTP::Get.new(uri.path.presence || "/")
      request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
      request["Accept-Language"] = "ja,en-US;q=0.9,en;q=0.8"
      request["Accept-Encoding"] = "gzip, deflate, br"
      request["Connection"] = "keep-alive"
      request["Upgrade-Insecure-Requests"] = "1"
      request["Sec-Fetch-Dest"] = "document"
      request["Sec-Fetch-Mode"] = "navigate"
      request["Sec-Fetch-Site"] = "none"
      request["Sec-Fetch-User"] = "?1"
      request["Cache-Control"] = "max-age=0"

      response = http.request(request)
      status = response.code.to_i

      if status >= 200 && status < 400
        landmark.update!(url_status: "valid", url_checked_at: Time.current)
      else
        landmark.update!(url_status: "invalid_#{status}", url_checked_at: Time.current)
      end
    rescue => e
      landmark.update!(url_status: "error_#{e.message}", url_checked_at: Time.current)
    end
  end
end
