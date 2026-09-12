class CreateRegions < ActiveRecord::Migration[8.1]
  def change
    create_table :regions do |t|
      t.string :name, null: false
      t.string :hiragana, null: false

      t.timestamps
    end
    add_index :regions, :name, unique: true
    add_index :regions, :hiragana
  end
end
