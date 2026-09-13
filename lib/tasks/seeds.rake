namespace :seeds do
  desc "Dump regions, tags, landmarks and taggings to db/seeds TSV files"
  task dump: :environment do
    seeds_dir = Rails.root.join("db", "seeds")
    files = Seeds::Dumper.new.call

    counts = {}
    files.each do |filename, content|
      File.write(seeds_dir.join(filename), content)
      counts[filename] = CSV.parse(content, col_sep: "\t", headers: true).size
    end

    puts "Regions: #{counts['regions.tab']} records"
    puts "Tags: #{counts['tags.tab']} records"
    puts "Landmarks: #{counts['landmarks.tab']} records"
    puts "Taggings: #{counts['taggings.tab']} records"
  end
end
