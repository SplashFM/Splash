class MediaCenter extends Backbone.View
  events:
    play: 'play'

  initialize: ->
    @player = @options.player

  play: (_, data) ->
    @player.play(data.track)

window.MediaCenter = MediaCenter