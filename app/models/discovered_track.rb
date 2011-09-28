class DiscoveredTrack < Track
  def purchase_url
    purchase_url_raw
  end

  def purchasable?
    purchase_url.present?
  end
end
