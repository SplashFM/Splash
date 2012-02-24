window.Feed = (args) ->
  p = Paginate(args.collection, 10, args.filters)
  l = _.extend(
    new BoundList(className: args.className, collection: args.collection),
    newItem: args.newItem)

  p.fetchNext()

  l.el
