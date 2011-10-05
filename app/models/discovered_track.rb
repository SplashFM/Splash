class DiscoveredTrack < Track
  def preview_type
    "m4a"
  end

  def purchase_url
    purchase_url_raw
  end

  def purchasable?
    purchase_url.present?
  end
end
