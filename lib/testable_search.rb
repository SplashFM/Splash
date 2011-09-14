module TestableSearch
  def using_postgres?
    connection.class.name =~ /PostgreSQL/
  end

  def use_slow_search?
    Rails.env.test? && ! using_postgres?
  end
end
