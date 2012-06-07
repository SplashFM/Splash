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
    filters =
      top:       true
      following: if @sample == 'following' then 1 else ''
      week:      if @period == '7d' then 1 else ''
    @feed   = Feed.feed this,
      Feed.emptiable @sample,
        collection: new TrackList
        className: 'splashboard-items live-feed'
        filters: filters
        newItem: (i) -> new TopTrack(model: i)

    Feed.playable this,
                  @feed,
                  Mapper(Paginate(new TrackList, 10, filters),
                         (e) -> if e? then e.toJSON() else e),
                  filters

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

  initialize: ->
    @expand = true

  expanded: ->
    @render true

  render: (expanded) ->
    json = track: @model.toJSON(), user: false, expanded: expanded

    @$el.html($($.tmpl(@template, json)))

    @number = new Feed.Splash.FlipNumber({
      el: $('.the_splash_count',@el).get(0),
      value: @model.get('splash_count')
    }).render()

    new FullSplashAction
      model: @model
      el: @$('[data-widget = "full-splash-action"]').get(0),

    @download = new Toggle
      el:        @$('[data-widget = "no_download"]')
      target:    this.$('form')
      isEnabled: true

    @$('[data-widget = "play"]').hover(@togglePlay, @togglePlay)

    if expanded
      $(@el).addClass('expanded')

      new Feed.Splash.Lineage
        el:              @$('[data-widget = "thumbnails"]').get(0)
        model:           new Track(@model)

    this

  getTracks: (track_collection) =>
    track_list = [] 
    i = 0
    while i < track_collection.length  
      track_list.push (track_collection[i].toJSON())
      i++
    return track_list

  play: (e) ->
    e.preventDefault()

    @$el.trigger 'play', track: @model.toJSON(), track_list: @getTracks(@model.collection.models)

  togglePlay: => @$el.toggleClass 'playable'

window.Feed.Splash.Splashable.mixInto TopTrack, (topTrack) ->
  topTrack.model.toJSON()
window.Feed.Splash.Expandable.mixInto(TopTrack)
window.Feed.Splash.Reportable.mixInto TopTrack, (topTrack) ->
  new UndiscoveredTrack(topTrack.model.toJSON())

window.Home.TopTracks = TopTracks

$ ->
  TopTrack.prototype.template = $('#tmpl-event-splash').template()
