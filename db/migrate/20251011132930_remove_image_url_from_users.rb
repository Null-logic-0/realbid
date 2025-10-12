class RemoveImageUrlFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :image_url, :string
  end
end
