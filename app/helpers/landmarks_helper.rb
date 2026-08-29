module LandmarksHelper
  def status_class(status)
    case status
    when /404/
      "status-404"
    when /403/
      "status-403"
    when /ERROR/
      "status-error"
    else
      "status-other"
    end
  end
end
