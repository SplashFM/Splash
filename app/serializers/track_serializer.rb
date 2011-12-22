class TrackSerializer < ActiveModel::Serializer
  attributes :id, :title, :artwork_url, :preview_url, :preview_type

  def as_json(opts = nil)
    super((opts || {}).merge!(:root => false))
  end

  private

  def attributes
    super.tap { |h|
      h[:splashable]   = ! scope.try(:splashed?, track)
      h[:albums]       = albums
      h[:performers]   = performers
      h[:splash_count] = if @options[:scoped_score]
                           track.scoped_splash_count
                         else
                           track.splash_count
                         end
    }
  end

  def albums
    track.albums.to_sentence
  end

  def performers
    track.performers.to_sentence
  end
end
