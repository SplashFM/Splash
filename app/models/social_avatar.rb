class SocialAvatar
  def after_add(user, c)
    fetch_avatar(c.avatar_url) { |a|
      user.update_attributes! :avatar => a
    } unless user.avatar?
  end

  def fetch_avatar(url, &block)
    Tempfile.open('avatar') { |f|
      f.binmode
      f.write open(URI.encode(url)).read

      block.call f
    }
  rescue OpenURI::HTTPError => e
    logger.error e

    nil
  end
end
