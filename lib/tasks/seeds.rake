namespace :seeds do
  desc "Dump regions, tags, landmarks and taggings to db/seeds TSV files"
  task dump: :environment do
    require "csv"

    seeds_dir = Rails.root.join("db", "seeds")

    region_id_map = {}
    CSV.open(seeds_dir.join("regions.tab"), "w", col_sep: "\t") do |csv|
      csv << %w[id name hiragana created_at updated_at]
      Region.order(:id).each_with_index do |region, index|
        tab_id = index + 1
        region_id_map[region.id] = tab_id
        csv << [ tab_id, region.name, region.hiragana, region.created_at, region.updated_at ]
      end
    end
    puts "Regions: #{region_id_map.size} records"

    tag_id_map = {}
    CSV.open(seeds_dir.join("tags.tab"), "w", col_sep: "\t") do |csv|
      csv << %w[id name created_at updated_at]
      Tag.order(:id).each_with_index do |tag, index|
        tab_id = index + 1
        tag_id_map[tag.id] = tab_id
        csv << [ tab_id, tag.name, tag.created_at, tag.updated_at ]
      end
    end
    puts "Tags: #{tag_id_map.size} records"

    landmark_id_map = {}
    CSV.open(seeds_dir.join("landmarks.tab"), "w", col_sep: "\t") do |csv|
      csv << %w[id name region latitude longitude url question answer1 answer2 answer3
        correct created_at updated_at hiragana url_status url_checked_at]
      Landmark.order(:id).each_with_index do |landmark, index|
        tab_id = index + 1
        landmark_id_map[landmark.id] = tab_id
        csv << [
          tab_id,
          landmark.name,
          landmark.region&.name,
          landmark.latitude,
          landmark.longitude,
          landmark.url,
          landmark.question,
          landmark.answer1,
          landmark.answer2,
          landmark.answer3,
          landmark.correct,
          landmark.created_at,
          landmark.updated_at,
          landmark.hiragana,
          landmark.url_status,
          landmark.url_checked_at
        ]
      end
    end
    puts "Landmarks: #{landmark_id_map.size} records"

    tagging_count = 0
    CSV.open(seeds_dir.join("taggings.tab"), "w", col_sep: "\t") do |csv|
      csv << %w[id landmark_id tag_id created_at updated_at]
      Tagging.order(:id).each_with_index do |tagging, index|
        next unless landmark_id_map[tagging.landmark_id] && tag_id_map[tagging.tag_id]

        tagging_count += 1
        csv << [
          index + 1,
          landmark_id_map[tagging.landmark_id],
          tag_id_map[tagging.tag_id],
          tagging.created_at,
          tagging.updated_at
        ]
      end
    end
    puts "Taggings: #{tagging_count} records"
  end
end
