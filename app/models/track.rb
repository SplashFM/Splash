class Track
  attr_accessor :favorites, :source, :plays, :title, :uri

  class << self
    attr_accessor :max_results, :sources

    def search(filter)
      sources.inject([]) { |a, s| a + s.search(filter, :limit => max_results) }
    end
  end

  def initialize(fields)
    fields.each { |f, v| send "#{f}=", v }
  end
end

load 'config/initializers/searching.rb' if Rails.env.development?
