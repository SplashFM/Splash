class SoundCloudClient
  def search(query, opts)
    @sc.get('/tracks', :q => query, :order => 'hotness').
      select { |e| query.split(/(\s+|,)/).all? { |w| e.title.downcase =~ /#{w}/ } }.
      sort { |a, b|
        a.favoritings_count.to_i <=> b.favoritings_count.to_i
    }.reverse.first(opts[:limit]).map { |e|
      Track.new(:favorites  => e.favoritings_count,
                :plays      => e.playback_count,
                :source     => 'soundcloud',
                :title      => e.title,
                :uri        => e.uri)
    }
  end

  private

  def initialize(opts)
    @sc = Soundcloud.new(opts)
  end
end
