class PageWrapper
  attr_reader :page

  def initialize(page)
    @page = page
  end

  def inspect
    if system('which html2text')
      IO.popen("html2text", "w+") do |io|
        io.puts page.body
        io.close_write
        io.read
      end
    else
      super
    end
  end

  def t(*args)
    I18n.t(*args)
  end
end
