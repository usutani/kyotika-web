require "test_helper"

class SeedsDumpJobTest < ActiveJob::TestCase
  test "writes seeds.zip and completed status" do
    with_export_dir do |export_dir|
      SeedsDumpJob.perform_now

      assert_equal "completed", File.read(export_dir.join("status")).strip
      assert export_dir.join("seeds.zip").exist?

      entries = []
      Zip::File.open(export_dir.join("seeds.zip").to_s) do |zip|
        zip.each { |entry| entries << entry.name }
      end
      assert_equal %w[regions.tab tags.tab landmarks.tab taggings.tab], entries
    end
  end
end
