class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false, default: "京チカ"
      t.string :join_code, null: false
      t.integer :singleton_guard, null: false, default: 0

      t.timestamps
    end

    add_index :accounts, :join_code, unique: true
    add_index :accounts, :singleton_guard, unique: true
  end
end
