class SongFile
  class Metadata < Struct.new(:title, :artist, :album, :artwork); end

  class TranscodeError < StandardError; end
  class UnknownFormat  < StandardError; end

  extend Forwardable

  def_delegators :metadata, :title, :album, :artist, :artwork

  attr_reader :path, :format

  def initialize(path)
    @format = extract_format(path) or
      raise UnknownFormat, "Unknown format for path: #{path}"
    @path   = path
  end

  def extension
    format.to_s
  end

  private

  def extract_format(path)
    ext = File.extname(path).presence

    sane_format(ext[1..-1]) if ext
  end

  def metadata
    @metadata ||=
      begin
        if @format == :mp3
          f = TagLib::MPEG::File.new(path)
          t = f.id3v2_tag
          p = t.frame_list('APIC').first

          if p
            pic = Tempfile.new('artwork')
            pic.syswrite(p.picture)
          end

          if t.title.blank? && f.id3v1_tag.title.present?
            t = f.id3v1_tag
          end
        else
          f = TagLib::FileRef.new(path)
          t = f.tag
        end

        Metadata.new(t.title, t.artist, t.album, pic)
      ensure
        f.close
      end
  end

  def sane_format(format)
    format.to_sym
  end
end
