class Track < ActiveRecord::Base
  validates_presence_of :title, :artist
end
