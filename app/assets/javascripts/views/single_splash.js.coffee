class SingleSplash extends Page.Content
  initialize: ->
    super

    @routes = @app.routers.home.builder

  renderTop: ($top) ->
    Home.TopTracks::renderTop.call(this, $top)

  renderMain: ($main) ->
    $ul = $('<ul class="live-feed" />')
    fs  = new Feed.Splash
      model: @model
      disableToggling: true
      currentUserID: @app.user.id

    $ul.append fs.render().el

    $main.html $ul

window.SingleSplash = SingleSplash
