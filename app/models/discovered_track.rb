class DiscoveredTrack < Track
  def as_json(opts = {})
    super(opts).
      merge!(:purchase_url => purchase_url)
  end

  def preview_type
    "m4a"
  end

  def preview_url
    read_attribute(:preview_url)
  end

  def purchase_url
    purchase_url_raw
  end

  def purchasable?
    purchase_url.present?
  end
end
