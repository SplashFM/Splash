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
        new Cursor(data.collection, data.index)
      else
        new Cursor.Null(data.track)

    @cursor.track (track) => @play track

  playDone: ->
    @cursor.next (cursor) => @play (@cursor = cursor).track()


class Cursor
  constructor: (collection, index, skip = {}) ->
    @collection = collection
    @index      = index

  next: (callback) ->
    getNew @collection, @index + 1, callback

  track: (callback) ->
    @_track = @collection.at @index, (track) =>
      @_track = track

      if callback? then callback track

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