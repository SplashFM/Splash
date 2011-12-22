class DiscoveredTrackSerializer < TrackSerializer
  private

  def attributes
    super.tap { |h| h[:purchase_url] = discovered_track.purchase_url }
  end
end
