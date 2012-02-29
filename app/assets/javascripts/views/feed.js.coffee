window.Feed =
  feed: (args) ->
    load       = ->
      $spin.html $('<div id="loading-spinner" class="loading-spinner" />')

      coll.fetchNext()

    bindLoaded =  ->
      coll.bind 'loaded', ->
        unless coll.hasNext()
          $spin.html $('<p class="loaded"/>').text I18n.t('events.all_loaded')

    bindScroll = =>
      f = -> if coll.hasNext() then coll.fetchNext()

      scroll.bind 'scroll', f

      @remove = _.wrap _.bind(@remove, this), (remove) ->
        scroll.unbind 'scroll', f
        remove()

    l = _.extend(
      new BoundList(className: args.className, collection: args.collection),
      newItem: args.newItem)

    coll   = Paginate(args.collection, 10, args.filters)
    $spin  = @$(@spinner)
    scroll = @app.scroll

    bindScroll()
    bindLoaded()
    load()

    l.el

  eventFeed: (filters) ->
    @feed
      collection: new EventList
      className:  'live-feed'
      filters:    filters
      newItem:    (i) => new Feed.Splash(model: i, currentUserID: @app.user.id)
