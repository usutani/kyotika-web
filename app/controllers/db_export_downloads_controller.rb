class DbExportDownloadsController < ApplicationController
  before_action :ensure_administrator

  def show
    export_dir = SeedsDumpJob.export_dir
    zip_path = export_dir.join("seeds.zip")

    if zip_path.exist?
      send_file zip_path,
        filename: "seeds_#{Time.current.strftime('%Y%m%d_%H%M%S')}.zip",
        type: "application/zip",
        disposition: "attachment"
    else
      redirect_to db_export_path, alert: "ファイルが見つかりません"
    end
  end
end
