class Splash < ActiveRecord::Base
  belongs_to :track
  belongs_to :user

  validates :track_id, :presence => true, :uniqueness => {:scope => :user_id}
  validates :user_id,  :presence => true
end
