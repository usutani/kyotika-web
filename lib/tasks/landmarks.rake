namespace :landmarks do
  desc "Check validity of all landmark URLs"
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

        response = http.request_head(uri.path.presence || "/")
        status = response.code.to_i
        valid = status >= 200 && status < 400

        icon = valid ? "\u2713" : "\u2717"
        puts "#{icon} [#{status}] ID:#{landmark.id} #{landmark.name} -> #{landmark.url}"
      rescue => e
        puts "\u2717 [ERROR] ID:#{landmark.id} #{landmark.name} -> #{landmark.url} (#{e.message})"
      end
    end
  end
end
