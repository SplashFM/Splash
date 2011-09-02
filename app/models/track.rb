class Track < ActiveRecord::Base
  validates_presence_of :title, :artist

  MAX_RESULTS = 3

  def self.using_postgres?
    connection.class.name =~ /PostgreSQL/
  end

  # Search for tracks matching the given query.
  #
  # Searches all "string" fields on the Track model.
  #
  # @param [String] query the query used to filter tracks
  #
  # @return a (possibly empty) list of tracks
  def self.filtered(query)
    if Rails.env.test? && ! using_postgres?
      # We want to use memory-based sqlite3 for most tests.
      # This is ugly, but tests run faster

      fields = content_columns.select { |c| c.type == :string }.map(&:name)
      q      = fields.map { |f| "#{f} = :query" }.join(' or ')

      where([q, {:query => query}])
    else
      search(query)
    end
  end
end
