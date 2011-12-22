class UndiscoveredTrackSerializer < TrackSerializer
  private

  def attributes
    super.tap { |h| h[:download_url] = undiscovered_track.download_url }
  end
end
