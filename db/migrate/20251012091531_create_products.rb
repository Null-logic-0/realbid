class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title
      t.string :description
      t.integer :starting_bid
      t.integer :auction_duration

      t.timestamps
    end
  end
end
