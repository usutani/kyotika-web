class SeedsDumpJob < ApplicationJob
  queue_as :default

  def self.export_dir
    Rails.root.join("tmp", "exports")
  end

  def perform
    export_dir = self.class.export_dir
    FileUtils.mkdir_p(export_dir)

    files = Seeds::Dumper.new.call

    zip_path = export_dir.join("seeds.zip")
    Zip::OutputStream.open(zip_path.to_s) do |zip|
      files.each do |filename, content|
        zip.put_next_entry(filename)
        zip.write(content)
      end
    end

    File.write(export_dir.join("status"), "completed")
  rescue StandardError => e
    File.write(export_dir.join("status"), "failed: #{e.message}")
  end
end
