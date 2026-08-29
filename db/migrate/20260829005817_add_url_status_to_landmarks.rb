class AddUrlStatusToLandmarks < ActiveRecord::Migration[8.1]
  def change
    add_column :landmarks, :url_status, :string
    add_column :landmarks, :url_checked_at, :datetime
  end
end
