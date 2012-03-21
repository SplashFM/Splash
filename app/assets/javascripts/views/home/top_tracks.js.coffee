class PeriodToggle extends Backbone.View
  className: 'splashboard-period'
  events:
    'change input': '_periodToggled'

  initialize: ->
    @app    = @options.app
    @sample = @options.sample
    @period = @options.period

  render: ->
    @$el.html JST['home/period_toggle']()

    @$('input').attr('checked', @period == 'alltime')

    this

  _periodToggled: (e) ->
    period = if @period == '7d' then 'alltime' else '7d'
    route  = @app.routers.home.builder.topTracks(period, @sample)

    Backbone.history.navigate route, trigger: true


class TopTracks extends Page.Content
  label: 'home.top_splashes'

  initialize: ->
    super

    @period = @options.period
    @sample = @options.sample
    @feed   = Feed.feed this,
      collection: new TrackList
      className: 'splashboard-items live-feed'
      filters:
        top:       true
        following: if @sample == 'following' then 1 else ''
        week:      if @period == '7d' then 1 else ''
      newItem: (i) -> new TopTrack(model: i)

    @routes = @app.routers.home.builder

  renderTop: ($top) ->
    periodToggle = new PeriodToggle(app: @app, period: @period, sample: @sample)

    $top.append periodToggle.render().el
    $top.append JST['shared/nav_list'](
      links: [{
        href:  @routes.topTracks(@period, 'following')
        label: 'top.following'
      }, {
        href:  @routes.topTracks(@period, 'everyone')
        label: 'top.everyone'}]
      active:  "top.#{@sample}"
    )


class TopTrack extends Backbone.View
  tagName: "li"
  events:
    'click [data-widget = "play"]': 'play'

  render: ->
    json = {track: @model.toJSON(), user: false}

    $($.tmpl(@template, json)).appendTo(@el)

    SPLASH.Widgets.numFlipper $('.the_splash_count', @el)

    new FullSplashAction
      model: @model
      el: @$('[data-widget = "full-splash-action"]').get(0),

    @$('[data-widget = "play"]').hover(@togglePlay, @togglePlay)

    this

  play: (e) ->
    e.preventDefault()

    @$el.trigger 'play', track: @model.toJSON()

  togglePlay: => @$el.toggleClass 'playable'

window.Home.TopTracks = TopTracks

$ ->
  TopTrack.prototype.template = $('#tmpl-event-splash').template()
