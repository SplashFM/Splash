class SongFile
  class Metadata < Struct.new(:title, :artist, :album, :artwork); end

  class TranscodeError < StandardError; end
  class UnknownFormat  < StandardError; end

  extend Forwardable

  def_delegators :metadata, :title, :album, :artist, :artwork

  def initialize(path)
    @default_format = extract_format(path) or
      raise UnknownFormat, "Unknown format for path: #{path}"

    store_format @default_format, path
  end

  def path(format = nil)
    f = format || @default_format

    ensure_format f

    get(f)
  end

  private

  def get(format)
    @paths[sane_format(format)]
  end

  def ensure_format(format)
    unless have_format?(format)
      path = transcode(@default_format, format)

      store_format format, path
    end
  end

  def extract_format(path)
    ext = File.extname(path).presence

    sane_format(ext[1..-1]) if ext
  end

  def metadata
    @metadata ||=
      begin
        if @default_format == :mp3
          f = TagLib::MPEG::File.new(path)
          t = f.id3v2_tag
          p = t.frame_list('APIC').first

          if p
            pic = Tempfile.new('artwork')
            pic.syswrite(p.picture)
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

  def have_format?(format)
    @paths[sane_format(format)]
  end

  def path_for(from, format)
    ext = File.extname(from)
    f   = File.basename(from, ext)

    Paperclip::Tempfile.new([f, ".#{format}"]).tap { |t| t.close }.path
  end

  def sane_format(format)
    format.to_sym
  end

  def store_format(format, path)
    (@paths ||= {})[sane_format(format)] = path
  end

  def transcode(format_from, format_to)
    from = get(format_from)

    path_for(from, format_to).tap { |to|
      # transcode file, overwriting what's there (created by Tempfile)
      out = `ffmpeg -y -i #{from} #{to} 2>&1`

      raise TranscodeError, out unless $?.exitstatus == 0
    }
  end
end

