class CreateLandmarks < ActiveRecord::Migration[8.1]
  def change
    create_table :landmarks do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :url
      t.string :question
      t.string :answer1
      t.string :answer2
      t.string :answer3
      t.integer :correct
      t.string :author
      t.string :hiragana

      t.timestamps
    end
  end
end
