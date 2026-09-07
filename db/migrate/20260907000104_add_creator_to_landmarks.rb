class AddCreatorToLandmarks < ActiveRecord::Migration[8.1]
  def change
    add_reference :landmarks, :creator, foreign_key: { to_table: :users }
  end
end
