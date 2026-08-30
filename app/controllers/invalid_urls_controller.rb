class InvalidUrlsController < ApplicationController
  def index
    @page_title = "Invalid URLs"
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

  private

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
