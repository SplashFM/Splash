class Splash < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :track
  belongs_to :user
  belongs_to :parent, :class_name => 'Splash'

  has_many :comments, :order => 'created_at asc', :dependent => :destroy
  has_many :resplashes, :class_name => 'Splash', :foreign_key => 'parent_id'

  validates :user_id,  :presence => true
  validates :track_id, :presence => true, :uniqueness => {:scope => :user_id}

  before_create :freeze_hierarchies, :if => :resplash?
  before_create :set_comment

  scope :by_date, order(:created_at)
  scope :for_tracks, lambda { |track_ids|
    track_ids.blank? ? scoped : where(:track_id => track_ids)
  }
  scope :for_users, lambda { |user_ids|
    user_ids.blank? ? scoped : where(:user_id => user_ids)
  }
  scope :from_last_splash, lambda { |splash_id|
    splash_id.blank? ? scoped : where("id < :id", {:id => splash_id})
  }
  scope :since, lambda { |time|
    time.blank? ? scoped : where(['created_at > ?', Time.parse(time).utc])
  }
  scope :with_tags, lambda { |tags|
    tags.blank? ? scoped : joins(:track => :tags).where(:tags => {:name => tags})
  }
  scope :as_event, select("distinct splashes.created_at,
                                    splashes.id target_id,
                                    'Splash' target_type")
  scope :mentioning, lambda { |user_ids|
    if user_ids.blank?
      scoped
    else
      joins(:comments).
      joins("join notifications n on
               n.target_id = comments.id and n.target_type = 'Comment'").
      where('n.notified_id in (?)', user_ids)
    end
  }
  scope :with_users, includes(:user)

  # Return the Splashes for a given user or users.
  #
  # @param user the owner or owners of the Splashes
  # @param track a (possibly splashed) track
  #
  # @return A (possibly empty) list of splashes, if only the user is passed in.
  #   Otherwise return a single Splash, or nil if no splash is found for the
  #   given user and track.
  def self.for(users, track = nil)
    users = users.respond_to?(:each) ? users : [users]

    r = where(:user_id => users.map(&:id))

    if track
      r.where(:track_id => track.id).first
    else
      r
    end
  end

  def self.for?(user, track)
    exists?(:track_id => track.id, :user_id => user.id)
  end

  def self.ids(user_id)
    s = arel_table

    connection.select_values(s.project(:id).where(s[:user_id].eq(user_id)).to_sql)
  end

  def comment=(body)
    @comment = body
  end

  def comments_count
    read_attribute(:comments_count).to_i
  end

  def owned_by?(user)
    self.user == user
  end

  def resplash?
    parent_id? || parent.present?
  end

  ##
  # Returns the (non-cached) splash's ripple count.
  #
  # WARNING: Existing clients of this method *expect* this to be the actual
  # value calculated from the DB. If the splash count later needs to be cached,
  # this method should still allow for a way to calculate the non-cached value
  # (or another method needs to be created and clients updated).
  def ripple_count
    resplashes.map(&:ripple_count).sum + resplashes.length
  end

  def user_path
    (user_list || '').split(',')
  end

  def user_path=(user_ids)
    self.user_list = user_ids.join(',')
  end

  private

  def freeze_hierarchies
    self.user_path = parent.user_path + [parent.user.id]
  end

  def set_comment
    if @comment
      comments.build(:body => @comment, :author => user, :splash_comment => true)
    end
  end
end
