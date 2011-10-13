class AddPopularityRankToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :popularity_rank, :integer
  end

  def self.down
    remove_column :tracks, :popularity_rank
  end
end
