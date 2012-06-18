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

      if splash.comments.first.try(:splash_comment)
        h[:comment] = splash.comments.first.body
      end

      if @options[:full]
        h[:unsplashable] = splash.user_id == scope.try(:id)
        h[:expanded]     = true
      end
      
      if @options[:creator]
        h[:creator]    = @options[:creator].nickname
        h[:creator_url]= @options[:creator].url
      end
    }
  end

  def comments
    if @options[:full]
      splash.comments.reject(&:splash_comment)
    else
      []
    end
  end
end
