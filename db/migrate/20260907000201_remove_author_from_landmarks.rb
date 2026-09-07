class RemoveAuthorFromLandmarks < ActiveRecord::Migration[8.1]
  def change
    remove_column :landmarks, :author, :string
  end
end
