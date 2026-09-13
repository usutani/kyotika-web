module Seeds
  class Dumper
    def call
      region_id_map = {}
      tag_id_map = {}
      landmark_id_map = {}

      regions_csv = generate_regions_csv(region_id_map)
      tags_csv = generate_tags_csv(tag_id_map)
      landmarks_csv = generate_landmarks_csv(landmark_id_map)
      taggings_csv = generate_taggings_csv(landmark_id_map, tag_id_map)

      {
        "regions.tab" => regions_csv,
        "tags.tab" => tags_csv,
        "landmarks.tab" => landmarks_csv,
        "taggings.tab" => taggings_csv
      }
    end

    private

    def generate_regions_csv(region_id_map)
      generate_csv(%w[id name hiragana created_at updated_at]) do |csv|
        Region.order(:id).each_with_index do |region, index|
          tab_id = index + 1
          region_id_map[region.id] = tab_id
          csv << [ tab_id, region.name, region.hiragana, region.created_at, region.updated_at ]
        end
      end
    end

    def generate_tags_csv(tag_id_map)
      generate_csv(%w[id name created_at updated_at]) do |csv|
        Tag.order(:id).each_with_index do |tag, index|
          tab_id = index + 1
          tag_id_map[tag.id] = tab_id
          csv << [ tab_id, tag.name, tag.created_at, tag.updated_at ]
        end
      end
    end

    def generate_landmarks_csv(landmark_id_map)
      generate_csv(%w[id name region latitude longitude url question answer1 answer2 answer3
        correct created_at updated_at hiragana url_status url_checked_at]) do |csv|
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
    end

    def generate_taggings_csv(landmark_id_map, tag_id_map)
      generate_csv(%w[id landmark_id tag_id created_at updated_at]) do |csv|
        tagging_count = 0
        Tagging.order(:id).each_with_index do |tagging, _index|
          next unless landmark_id_map[tagging.landmark_id] && tag_id_map[tagging.tag_id]

          tagging_count += 1
          csv << [
            tagging_count,
            landmark_id_map[tagging.landmark_id],
            tag_id_map[tagging.tag_id],
            tagging.created_at,
            tagging.updated_at
          ]
        end
      end
    end

    def generate_csv(headers)
      CSV.generate(col_sep: "\t") do |csv|
        csv << headers
        yield csv
      end
    end
  end
end
