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

  def db_status_class(status)
    case status
    when "valid"
      "status-valid"
    when /invalid/
      "status-invalid"
    when /error/
      "status-error"
    else
      "status-unchecked"
    end
  end

  def db_status_label(status)
    case status
    when "valid"
      "有効"
    when /invalid_(\d+)/
      "無効 (#{$1})"
    when /error_(.+)/
      "エラー"
    else
      "未チェック"
    end
  end
end
