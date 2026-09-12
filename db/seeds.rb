require "csv"

seeds_dir = Rails.root.join("db", "seeds")

# --- Regions ---
kyoto = Region.find_or_create_by!(name: "京都") do |region|
  region.hiragana = "きょうと"
end
kobe = Region.find_or_create_by!(name: "神戸市中央区") do |region|
  region.hiragana = "こうべしちゅうおうく"
end
puts "Regions: #{Region.count} records"

# --- Tags ---
tag_id_map = {}
CSV.foreach(seeds_dir.join("tags.tab"), col_sep: "\t", headers: true) do |row|
  tag = Tag.find_or_create_by!(name: row["name"])
  tag_id_map[row["id"].to_i] = tag.id
end
puts "Tags: #{Tag.count} records"

# --- Landmarks ---
landmark_id_map = {}
CSV.foreach(seeds_dir.join("landmarks.tab"), col_sep: "\t", headers: true) do |row|
  landmark = Landmark.find_or_create_by!(name: row["name"], region: kyoto) do |l|
    l.latitude        = row["latitude"].to_f
    l.longitude       = row["longitude"].to_f
    l.url             = row["url"]
    l.question        = row["question"]
    l.answer1         = row["answer1"]
    l.answer2         = row["answer2"]
    l.answer3         = row["answer3"]
    l.correct         = row["correct"].to_i
    l.hiragana        = row["hiragana"]
    l.url_status      = row["url_status"]
    l.url_checked_at  = row["url_checked_at"]&.to_datetime
  end
  landmark_id_map[row["id"].to_i] = landmark.id
end

# --- Kobe example ---
event_tag = Tag.find_or_create_by!(name: "イベント")
sannomiya = Landmark.find_or_create_by!(name: "三宮中央通り", region: kobe) do |l|
  l.hiragana = "さんのみやちゅうおうどおり"
  l.latitude = 34.69065966554157
  l.longitude = 135.19239039135786
  l.url = "https://www.sun-tv.co.jp/suntvnews/news/2025/10/04/89787/"
  l.question = "2025年に行われた三宮VS元町の綱引きはどちらが勝ったでしょう。"
  l.answer1 = "三宮"
  l.answer2 = "元町"
  l.answer3 = "引き分け"
  l.correct = 2
end
Tagging.find_or_create_by!(landmark: sannomiya, tag: event_tag)
puts "Landmarks: #{Landmark.count} records"

# --- Taggings ---
CSV.foreach(seeds_dir.join("taggings.tab"), col_sep: "\t", headers: true) do |row|
  lm_id = landmark_id_map[row["landmark_id"].to_i]
  tg_id = tag_id_map[row["tag_id"].to_i]
  next unless lm_id && tg_id

  Tagging.find_or_create_by!(landmark_id: lm_id, tag_id: tg_id)
end
puts "Taggings: #{Tagging.count} records"
