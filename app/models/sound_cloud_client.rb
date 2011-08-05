class SoundCloudClient
  private

  def initialize(opts)
    @sc = Soundcloud.new(opts)
  end
end
