class AddTopSplasherWeightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :top_splasher_weight, :integer

  end
end
