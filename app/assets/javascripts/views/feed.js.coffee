window.Feed =
  feed: (args) ->
    p = Paginate(args.collection, 10, args.filters)
    l = _.extend(
      new BoundList(className: args.className, collection: args.collection),
      newItem: args.newItem)

    p.fetchNext()

    l.el

  eventFeed: (filters) ->
    @feed
      collection: new EventList
      className:  'live-feed'
      filters:    filters
      newItem:    (i) => new Feed.Splash(model: i, currentUserID: @app.user.id)
