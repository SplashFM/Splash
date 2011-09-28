class UndiscoveredTrack < Track
  def download_path
    data.path
  end

  def downloadable?
    data.file?
  end
end
