module TestableSearch
  def using_postgres?
    connection.class.name =~ /PostgreSQL/
  end

  def use_slow_search?
    ! Rails.env.production?
  end

  def ilike
    using_postgres? ? "ilike" : "like"
  end
end
