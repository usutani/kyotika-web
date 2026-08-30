module LandmarksHelper
  def status_class(status)
    case status
    when /404/
      "status-badge--404"
    when /403/
      "status-badge--403"
    when /ERROR/
      "status-badge--error"
    else
      "status-badge--other"
    end
  end

  def db_status_class(status)
    case status
    when "valid"
      "status-badge--valid"
    when /invalid/
      "status-badge--invalid"
    when /error/
      "status-badge--error"
    else
      "status-badge--unchecked"
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
