window.Feed =
  feed: (args) ->
    load = (fetch) ->
      $spin.html $('<div id="loading-spinner" class="loading-spinner" />')

      if fetch then coll.fetchNext()

    bindLoaded =  ->
      coll.bind 'loaded', ->
        unless coll.hasNext()
          $spin.html $('<p class="loaded"/>').text I18n.t('events.all_loaded')

      coll.bind 'paginate:error', -> $spin.html ''

    bindScroll = =>
      f = -> if coll.hasNext() then coll.fetchNext()

      scroll.bind 'scroll', f

      @remove = _.wrap _.bind(@remove, this), (remove) ->
        scroll.unbind 'scroll', f
        remove()

    if args.collection.fetchNext?
      coll    = args.collection
      rawColl = args.collection.collection()
    else
      coll    = Paginate(args.collection, 10, args.filters)
      rawColl = args.collection

    l = _.extend(
      new BoundList(className: args.className, collection: rawColl),
      newItem: args.newItem)

    $spin  = @$(@spinner)
    scroll = @app.scroll

    bindScroll()
    bindLoaded()
    load(if args.fetch? then args.fetch else true)

    l.el

  eventFeed: (filters) ->
    coll = new EventList

    update = new Feed.Updateable collection: coll, filters: filters

    @$top.append update.render().el

    @remove = _.wrap _.bind(@remove, this), (remove) ->
      update.remove()
      remove()

    @feed
      collection: coll
      className:  'live-feed'
      filters:    filters
      newItem:    (i) => new Feed.Splash(model: i, currentUserID: @app.user.id)


class Feed.Updateable extends Backbone.View
  events:
    click: 'reload'

  className:      'feed-updates-count no-new left'
  tagName:        'a'
  updateInterval: 60000

  initialize: ->
    @filters  = @options.filters
    @interval = setInterval @checkForUpdates, @updateInterval

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
