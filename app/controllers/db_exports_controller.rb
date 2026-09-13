class DbExportsController < ApplicationController
  before_action :ensure_administrator

  def new
    @previous_available = SeedsDumpJob.export_dir.join("seeds.zip").exist?
  end

  def create
    export_dir = SeedsDumpJob.export_dir
    FileUtils.mkdir_p(export_dir)
    FileUtils.rm_f([ export_dir.join("seeds.zip") ])
    File.write(export_dir.join("status"), "processing")
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
      redirect_to new_db_export_path
    end
  end
end
