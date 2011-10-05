class UndiscoveredTrack < Track
  def self.create_and_splash(fields, user, comment)
    track = create(fields)

    splash = if track.errors.empty?
               Splash.create(:track   => track,
                             :user    => current_user,
                             :comment => comment)
             elsif track.taken?
               Splash.create(:track   => track.canonical_version,
                             :user    => current_user,
                             :comment => comment)
             else
               # track has errors that prevent it from being splashed
               nil
             end

    [track, splash]
  end

  def preview_type
    File.extname(file_name).split('.').last
  end

  def preview_url
    data.url
  end

  alias_method :preview_url?, :preview_url

  def download_path
    data.path
  end

  def downloadable?
    data.file?
  end
end
