class Feed
  @emptiable: (sample, options) ->
    if sample == 'following'
      _.extend(options, empty: JST['shared/empty_feed']())
    else
      options

  @playable: (content, feed, collection, buildColl) ->
    content.events ?= {}

    playing         = (e, data) ->
      newColl = new collection.constructor(collection.toArray())

      unless data.skip
        _.extend data,
          index:      feed.list.indexOf(e.target)
          collection: buildColl(newColl)

    _.extend content.events, 'play': playing

    content.delegateEvents()

  @eventFeed: (content, options) ->
    coll   = new EventList
    params =
      _({
        app:        window.app,
        collection: coll,
        className:  'live-feed',
        newItem:    (i) ->
          new Feed.Splash(model: i, currentUserID: window.app.user.id)
        , refresh:  options.filters}).extend(options)
    feed   = @feed content, params

    # We should not be extending app events here
    if options.update? && ! options.update
      splashed = ->
    else
      splashed = _.bind(feed.splashed, feed)

    u        = params.app[params.app.events['upload:complete']]
    _.extend params.app.events,
      'splash:splash':   splashed
      'upload:complete': _.wrap(u, (f, rest...) ->
        f.call(params.app)
        splashed(rest...))

    params.app.delegateEvents()

    @playable content,
              feed,
              coll,
              (current) ->
                Mapper(Paginate(current, 10, params.filters),
                       (e) -> if e? then e.get('track') else e)

    feed

  @feed: (content, args) ->
    $spin = content.$(content.spinner)
    feed  = new Feed(_.extend({}, args, app: content.app, $spinner: $spin))

    remove = _.wrap _.bind(content.remove, content), (rm) ->
      feed.remove()
      rm()

    renderMain = _.wrap _.bind(content.renderMain, content), (r, $c) ->
      r $c
      feed.renderMain $c

    renderTop = _.wrap _.bind(content.renderTop, content), (r, $c) ->
      r $c
      feed.renderTop $c

    content.remove     = remove
    content.renderMain = renderMain
    content.renderTop  = renderTop

    feed

  constructor: (options) ->
    @app               = options.app
    @collection        = options.collection
    @filters           = options.filters
    @paginated         = Paginate(@collection, 10, @filters)
    @newItem           = options.newItem
    @className         = options.className
    @authErrorTemplate = options.authErrorTemplate or 'shared/login_required'
    @empty             = options.empty
    @allLoaded         = options.allLoaded

    @$spinner = options.$spinner

    @endless()

    if options.refresh then @updateable(options.refresh)

  endless: ->
    @spinner = new Feed.Spinner
      collection: @paginated
      el:         @$spinner
      empty:      @empty
      allLoaded:  @allLoaded

    @scroll  = new Feed.EndlessScroll(app: @app, collection: @paginated)

  load: ($main) ->
    @paginated.fetchNext().
      fail((xhr) =>
        if xhr.status == 401
          $main.prepend JST[@authErrorTemplate]()).
      done =>
        if @empty && @collection.isEmpty()
          $main.prepend @empty
    this

  splashed: (_, data) ->
    @collection.add data.splash, at: 0
    @collection.remove @collection.at(@collection.length - 1)

    true

  renderTop: ($top) ->
    if @updates then $top.append @updates.render().el

  renderMain: ($main) ->
    $main.append _.extend(
      @list = new BoundList(className: @className, collection: @collection),
      newItem: @newItem).el

    @load $main

  remove: ->
    @scroll.remove()

    if @updates then @updates.remove()

  updateable: (filters) ->
    @updates = new Feed.Updateable
      collection: @collection
      filters:    filters

    @updates.start()


class Feed.EndlessScroll extends Backbone.View
  initialize: ->
    @app     = @options.app
    @wscroll = @app.scroll

    @wscroll.bind 'scroll', @scroll

  remove: ->
    @wscroll.unbind 'scroll', @scroll

  scroll: =>
    if @collection.hasNext() then @collection.fetchNext()


class Feed.Spinner extends Backbone.View
  initialize: ->
    @empty     = @options.empty
    @allLoaded = @options.allLoaded || I18n.t('events.all_loaded')

    @collection.bind 'fetch',          @start
    @collection.bind 'loaded',         @stop
    @collection.bind 'paginate:error', @clear

  clear: =>
    @$el.html ''

  start: =>
    @$el.html $('<div id="loading-spinner" class="loading-spinner" />')

  stop: =>
    if @collection.hasNext()
      @clear()
    else if @collection.collection.isEmpty() && @empty
      @clear()
    else
      @$el.html $('<p class="loaded"/>').html @allLoaded


class Feed.Updateable extends Backbone.View
  events:
    click: 'reload'

  className:      'feed-updates-count no-new left'
  tagName:        'a'
  updateInterval: 60000

  initialize: ->
    @filters  = @options.filters

  checkForUpdates: =>
    @collection.updateCount @filters, @renderUpdateCount

  reload: ->
    @renderUpdateCount 0

    @collection.fetch data: @filters

  remove: ->
    clearInterval @interval

    @$el.remove()

  renderUpdateCount: (count) =>
    @$el.text I18n.t('events.updates', count: count)

    if count == 0 then @$el.addClass 'no-new' else @$el.removeClass 'no-new'

  start: ->
    @interval = setInterval @checkForUpdates, @updateInterval

window.Feed = Feed
