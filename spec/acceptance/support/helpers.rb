module Helpers
  def t(*args)
    I18n.t(*args)
  end

  def file(name)
    File.expand_path(File.dirname(__FILE__) + "/files/#{name}")
  end
end
