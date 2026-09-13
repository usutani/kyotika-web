class DbExportsController < ApplicationController
  before_action :ensure_administrator

  def create
    export_dir = SeedsDumpJob.export_dir
    FileUtils.mkdir_p(export_dir)
    FileUtils.rm_f([ export_dir.join("status"), export_dir.join("seeds.zip") ])
    SeedsDumpJob.perform_later
    redirect_to db_export_path
  end

  def show
    export_dir = SeedsDumpJob.export_dir
    status_file = export_dir.join("status")

    if status_file.exist?
      @status = File.read(status_file).strip
      @completed = @status == "completed"
      @failed = @status.start_with?("failed:")
    else
      @status = "processing"
      @completed = false
      @failed = false
    end
  end
end
