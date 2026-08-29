class UrlChecksController < ApplicationController
  def create
    @landmark = Landmark.find(params[:landmark_id])
    check_and_cache_url(@landmark)
    redirect_to invalid_urls_path, notice: "#{@landmark.name} の URL チェックが完了しました"
  end

  private

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
