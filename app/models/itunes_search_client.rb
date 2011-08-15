class ItunesSearchClient
  def search(query, opts)
    limit = opts[:limit] || 20

    ITunesSearchAPI.search(:term => query, :country => "US", :wrapperType => "track", :kind => "song",:media => "music", :limit => limit).
    map {|e|
      Track.new(:favorites  => 0,
                  :plays      => 0,
                  :source     => 'itunessearch',
                  :title      => "#{e["artistName"]} - #{e["trackName"]}",
                  :uri        => "#{e["previewUrl"]}")
    }
  end

  private

  def initialize()
  end
end
