module Helpers
  def file(name)
    File.expand_path(File.dirname(__FILE__) + "/files/#{name}")
  end
end
