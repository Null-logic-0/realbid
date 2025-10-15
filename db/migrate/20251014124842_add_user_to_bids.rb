class AddUserToBids < ActiveRecord::Migration[8.0]
  def change
    add_reference :bids, :user, null: false, foreign_key: true
  end
end
