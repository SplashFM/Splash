class PeriodToggle extends Backbone.View
  className: 'splashboard-period'
  events:
    'change input': '_periodToggled'

  initialize: ->
    @sample = @options.sample
    @period = @options.period

  render: ->
    @$el.html JST['home/period_toggle']()

    @$('input').attr('checked', @period == 'alltime')

    this

  _periodToggled: (e) ->
    period = if @period == '7d' then 'alltime' else '7d'
    route  = Home.Router.routes.topTracks(period, @sample)

    Backbone.history.navigate route, trigger: true



class TopTracks extends Page.Content
  label: 'home.top_splashes'

  initialize: ->
    super

    @period = @options.period
    @sample = @options.sample

    @routes       = Home.Router.routes

  renderTop: ($top) ->
    periodToggle = new PeriodToggle(period: @period, sample: @sample)

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

  renderMain: ($main) ->
    o =
      top:       true
      following: if @sample == 'following' then 1 else ''
      week:      if @period == '7d' then 1 else ''
    p = Paginate(c = new TrackList, 10, o)
    l = new L(className: 'splashboard-items live-feed', collection: c)

    p.fetchNext()

    $main.append l.el


class L extends BoundList
  newItem: (i) -> new TopTrack(model: i)


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

    @$el.trigger 'request:play', track: @model.toJSON()

  togglePlay: => @$el.toggleClass 'playable'

window.Home.TopTracks = TopTracks

$ ->
  TopTrack.prototype.template = $('#tmpl-event-splash').template()
