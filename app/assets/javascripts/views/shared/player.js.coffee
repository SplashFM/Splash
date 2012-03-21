class Player extends Backbone.View
  events:
    "splash:quick": "disableSplashButton"

  initialize: ->
    _.bindAll this, "play"
    $("body").bind "play", @play

  disableSplashButton: ->
    @$(".splash-btn").removeClass("splashable").addClass "unsplashable"

  enableSplashButton: ->
    @$(".splash-btn").removeClass("unsplashable").addClass "splashable"

  play: (_, data) ->
    media = {}
    media[data.track.preview_type] = data.track.preview_url
    @el = $("#player-area").get(0)
    $(@el).html $.tmpl(@template, data.track)
    $("[data-widget = 'player']").jPlayer
      cssSelectorAncestor: "[data-widget = \"player-ui\"]"
      swfPath: "/Jplayer.swf"
      supplied: data.track.preview_type
      ready: ->
        $(this).jPlayer("setMedia", media).jPlayer "play"

    new BaseApp.QuickSplashAction(
      el: @$(".splash-btn")
      model: new Track(data.track)
    )
    if data.track.splashable
      @enableSplashButton()
    else
      @disableSplashButton()
    @delegateEvents @events

    fixBG @$("#player-container")

window.Player = Player.mixin(Purchase)

$ ->
  Player::template = $('#tmpl-player').template()
