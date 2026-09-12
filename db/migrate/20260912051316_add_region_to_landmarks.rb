class AddRegionToLandmarks < ActiveRecord::Migration[8.1]
  def up
    add_reference :landmarks, :region, foreign_key: true
    kyoto = Region.find_or_create_by!(name: "京都") do |region|
      region.hiragana = "きょうと"
    end
    Landmark.where(region_id: nil).update_all(region_id: kyoto.id)
    change_column_null :landmarks, :region_id, false
  end

  def down
    remove_reference :landmarks, :region
  end
end
