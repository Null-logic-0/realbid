class CreateBids < ActiveRecord::Migration[8.0]
  def change
    create_table :bids do |t|
      t.integer :amount

      t.timestamps
    end
  end
end
