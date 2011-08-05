class SoundCloudClient
  def search(query)
    @sc.get('/tracks', :q => query, :order => 'hotness').
      select { |e| query.split(/(\s+|,)/).all? { |w| e.title.downcase =~ /#{w}/ } }.
      sort { |a, b|
        a.favoritings_count.to_i <=> b.favoritings_count.to_i
    }.reverse
  end

  private

  def initialize(opts)
    @sc = Soundcloud.new(opts)
  end
end
