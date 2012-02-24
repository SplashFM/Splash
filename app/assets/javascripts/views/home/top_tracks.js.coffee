class PeriodToggle extends Backbone.View
  className: 'splashboard-period'

  initialize: ->
    @period = @options.period

  render: ->
    @$el.html JST['home/period_toggle']()

    @$('input').attr('checked', @period == 'alltime')

    this


class TopTracks extends Page.Content
  label: 'home.top_splashes'

  initialize: ->
    super

    @period = @options.period
    @sample = @options.sample

    @routes       = Home.Router.routes

  renderTop: ($top) ->
    periodToggle = new PeriodToggle(period: @period)

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
