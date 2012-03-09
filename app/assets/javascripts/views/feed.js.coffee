class Feed
  @eventFeed: (content, filters) ->
    feed = @feed content,
      collection: new EventList
      className:  'live-feed'
      filters:    filters
      newItem:    (i) ->
        new Feed.Splash(model: i, currentUserID: window.app.user.id)
      refresh:    true

    splashed       = _.bind(feed.splashed, feed)
    content.events ?= {}

    _.extend content.events,
      'splash:splash':   splashed
      'upload:complete': splashed

    content.delegateEvents()

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
    @app        = options.app
    @collection = options.collection
    @filters    = options.filters
    @paginated  = Paginate(@collection, 10, @filters)
    @newItem    = options.newItem
    @className  = options.className

    @$spinner = options.$spinner

    @endless()

    if options.refresh then @updateable()

  endless: ->
    @spinner = new Feed.Spinner
      collection: @paginated
      el:         @$spinner

    @scroll  = new Feed.EndlessScroll(app: @app, collection: @paginated)

  load: ($main) ->
    @paginated.fetchNext().fail (xhr) ->
      if xhr.status == 401
        $main.prepend JST['shared/facebook_required']()

    this

  splashed: ->
    @paginated.refetch()

  renderTop: ($top) ->
    if @updates then $top.append @updates.render().el

  renderMain: ($main) ->
    $main.append _.extend(
      new BoundList(className: @className, collection: @collection),
      newItem: @newItem).el

    @load $main

  remove: ->
    @scroll.remove()

    if @updates then @updates.remove()

  updateable: ->
    @updates = new Feed.Updateable
      collection: @collection
      filters:    @filters

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
    @collection.bind 'fetch',          @start
    @collection.bind 'loaded',         @stop
    @collection.bind 'paginate:error', @clear

  clear: =>
    @$el.html ''

  start: =>
    @$el.html $('<div id="loading-spinner" class="loading-spinner" />')

  stop: =>
    unless @collection.hasNext()
      @$el.html $('<p class="loaded"/>').text I18n.t('events.all_loaded')


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
