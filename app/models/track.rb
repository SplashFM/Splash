class Track
  attr_accessor :favorites, :source, :plays, :title, :uri

  def initialize(fields)
    fields.each { |f, v| send "#{f}=", v }
  end
end
