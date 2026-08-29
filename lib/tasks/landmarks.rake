namespace :landmarks do
  desc "Check validity of all landmark URLs and cache results"
  task check_urls: :environment do
    require "net/http"
    require "uri"

    UNSAFE_CHARS = Regexp.new("[^a-zA-Z0-9\\-._~:/?#\\[\\]@!$&'+,;=%]")

    Landmark.order(:id).find_each do |landmark|
      next if landmark.url.blank?

      begin
        url = landmark.url.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
        encoded_url = URI::DEFAULT_PARSER.escape(url, UNSAFE_CHARS)

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
        valid = status >= 200 && status < 400

        if valid
          landmark.update!(url_status: "valid", url_checked_at: Time.current)
          puts "\u2713 [#{status}] ID:#{landmark.id} #{landmark.name} -> #{landmark.url}"
        else
          landmark.update!(url_status: "invalid_#{status}", url_checked_at: Time.current)
          puts "\u2717 [#{status}] ID:#{landmark.id} #{landmark.name} -> #{landmark.url}"
        end
      rescue => e
        landmark.update!(url_status: "error_#{e.message}", url_checked_at: Time.current)
        puts "\u2717 [ERROR] ID:#{landmark.id} #{landmark.name} -> #{landmark.url} (#{e.message})"
      end
    end
  end

  desc "Convert HTTP URLs to HTTPS where supported"
  task upgrade_to_https: :environment do
    https_supported_ids = [
      1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
      21, 22, 23, 24, 25, 27, 28, 29, 31, 32, 34, 35, 36, 38, 39, 40, 41,
      42, 43, 44, 45, 46, 49, 50, 51, 53, 54, 55, 57, 58, 60, 61, 62, 63,
      64, 65, 66, 68, 70, 71, 72, 74, 75, 76, 77, 78, 80, 83, 85, 89, 90, 91
    ]

    Landmark.where(id: https_supported_ids).find_each do |landmark|
      next if landmark.url.start_with?("https://")

      old_url = landmark.url
      new_url = old_url.sub("http://", "https://")
      landmark.update!(url: new_url)
      puts "ID:#{landmark.id} #{landmark.name}: #{old_url} -> #{new_url}"
    end
  end
end
