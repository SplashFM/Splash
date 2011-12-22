class SplashSerializer < ActiveModel::Serializer
  attributes :id, :comments_count, :created_at

  has_one  :track
  has_one  :user
  has_many :comments

  def as_json(opts = nil)
    super((opts || {}).merge!(:root => false))
  end

  private

  def attributes
    super.tap { |h|
      h[:type]       = 'splash'
      h[:splashable] = ! scope.try(:splashed?, splash.track_id)

      if @options[:full]
        h[:unsplashable] = splash.user_id == scope.try(:id)
        h[:expanded]     = true
      end
    }
  end

  def comments
    @options[:full] ? splash.comments : []
  end
end
