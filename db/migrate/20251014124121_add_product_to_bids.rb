class AddProductToBids < ActiveRecord::Migration[8.0]
  def change
    add_reference :bids, :product, null: false, foreign_key: true
  end
end
