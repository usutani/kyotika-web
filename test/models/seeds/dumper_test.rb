require "test_helper"

class Seeds::DumperTest < ActiveSupport::TestCase
  test "returns four TSV files" do
    files = Seeds::Dumper.new.call

    assert_equal %w[regions.tab tags.tab landmarks.tab taggings.tab], files.keys
  end

  test "regions are renumbered from 1" do
    files = Seeds::Dumper.new.call
    rows = CSV.parse(files["regions.tab"], col_sep: "\t", headers: true)

    assert_equal Region.count, rows.size
    assert_equal((1..Region.count).to_a, rows.map { |row| row["id"].to_i })
    assert_includes files["regions.tab"], "京都"
  end

  test "landmarks export region name" do
    files = Seeds::Dumper.new.call
    rows = CSV.parse(files["landmarks.tab"], col_sep: "\t", headers: true)

    assert_equal Landmark.count, rows.size
    kinkakuji = rows.find { |row| row["name"] == "金閣寺" }
    assert_equal "京都", kinkakuji["region"]
  end

  test "taggings reference renumbered ids" do
    files = Seeds::Dumper.new.call
    rows = CSV.parse(files["taggings.tab"], col_sep: "\t", headers: true)

    assert_equal Tagging.count, rows.size
    landmark_ids = CSV.parse(files["landmarks.tab"], col_sep: "\t", headers: true).map { |row| row["id"].to_i }
    tag_ids = CSV.parse(files["tags.tab"], col_sep: "\t", headers: true).map { |row| row["id"].to_i }
    rows.each do |row|
      assert_includes landmark_ids, row["landmark_id"].to_i
      assert_includes tag_ids, row["tag_id"].to_i
    end
  end
end
