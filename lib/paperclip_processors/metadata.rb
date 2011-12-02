require 'song_file'

module Paperclip
  class Metadata < Processor
    def make
      song  = SongFile.new(@file.path)
      track = @attachment.instance

      track.title      = song.title
      track.albums     = song.album
      track.performers = song.artist
      track.artwork    = song.artwork

      @file
    end
  end
end
