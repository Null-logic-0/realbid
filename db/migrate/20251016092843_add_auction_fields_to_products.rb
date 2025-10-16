class AddAuctionFieldsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :auction_status, :string
    add_column :products, :winner_id, :integer
  end
end
