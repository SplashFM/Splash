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
        new Cursor(data.track_list, data.track, data.index)
      else
        new Cursor.Null(data.track)

    @cursor.track (track) => @play track

  playDone: ->
    @cursor.next (cursor) => @play (@cursor = cursor).track()


class Cursor
  constructor: (collection, track, index) ->
    @collection = collection
    @_track     = track
    @index      = index

  next: (callback) ->
    i = @index
    while true
      t = @collection[i].get('track')
      break if !t || t.id == @_track.id
      i++
    getNew @collection, i + 1, callback

  track: (callback) ->
    if callback? then callback @_track
    @_track

  getNew = (collection, at, callback) ->
    track = collection[at].get('track')
    if track?
      if track.download_url?
        @_track = track
        callback new Cursor(collection, track, at)
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
