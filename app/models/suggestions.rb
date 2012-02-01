class Suggestions
  def after_add(user, conn)
    friends =
      User.with_social_connection(conn.provider, conn.friends.map(&:uid))

    user.add_suggestions friends.map(&:id)

    friends.each { |f| f.add_suggestions conn.user.id }
  end
end
