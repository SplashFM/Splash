class MediaCenter extends Backbone.View
  events:
    'play': 'playRequest'
    'play:done': 'playDone'

  initialize: ->
    @player = @options.player

  play: (track) ->
    @player.play track

  playRequest: (_, data) ->
    @cursor =
      if data.index?
        new Cursor(data.collection, data.index, data.track)
      else
        new Cursor.Null(data.track)

    @cursor.track (track) => @play track

  playDone: ->
    @cursor.next (cursor) => @play (@cursor = cursor).track()


class Cursor
  constructor: (collection, index, track) ->
    @collection = collection
    @index      = index
    @_track     = track

  next: (callback) ->
    i = 0
    while true
      t = @collection.at(i)
      break if !t || t.id == @_track.id
      i++
    getNew @collection, i + 1, callback

  track: (callback) ->
    t = @_track

    @_track = @collection.at @index, (track) =>
      @_track = track

      if callback? then callback track

    @_track or t

  getNew = (collection, at, callback) ->
    collection.at at, (track) ->
      if track?
        if track.download_url?
          callback new Cursor(collection, at)
        else
          getNew collection, at + 1, callback


class Cursor.Null
  constructor: (track) ->
    @_track = track

  next: ->

  track: (callback) ->
    if callback? then callback(@_track)

    @_track

window.MediaCenter = MediaCenter