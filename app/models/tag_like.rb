module TagLike
  include TestableSearch

  def filter(name)
    where("name #{ilike} ?", "#{name}%")
  end
end
