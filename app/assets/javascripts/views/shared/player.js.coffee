class Player extends Backbone.View
  events:
    "splash:quick": "disableSplashButton"

  disableSplashButton: ->
    @$(".splash-btn").removeClass("splashable").addClass "unsplashable"

  enableSplashButton: ->
    @$(".splash-btn").removeClass("unsplashable").addClass "splashable"

  play: (track) ->
    media = {}
    media[track.preview_type] = track.preview_url
    @el = $("#player-area").get(0)
    $(@el).html $.tmpl(@template, track)
    $("[data-widget = 'player']").jPlayer
      cssSelectorAncestor: "[data-widget = \"player-ui\"]"
      swfPath: "/Jplayer.swf"
      supplied: track.preview_type
      ready: ->
        $(this).jPlayer("setMedia", media).jPlayer "play"

    # TODO: move this out
    new BaseApp.QuickSplashAction(
      el: @$(".splash-btn")
      model: new Track(track)
    )
    if track.splashable
      @enableSplashButton()
    else
      @disableSplashButton()
    @delegateEvents @events

    fixBG @$("#player-container")

window.Player = Player.mixin(Purchase)

$ ->
  Player::template = $('#tmpl-player').template()
