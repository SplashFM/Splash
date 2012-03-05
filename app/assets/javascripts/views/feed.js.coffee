window.Feed =
  feed: (args) ->
    $main = @$main

    load = ->
      coll.fetchNext().fail (xhr) ->
        if xhr.status == 401
          $main.prepend JST['shared/facebook_required']()

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

    coll = Paginate(args.collection, 10, args.filters)

    l = _.extend(
      new BoundList(className: args.className, collection: args.collection),
      newItem: args.newItem)

    $spin  = @$(@spinner)
    scroll = @app.scroll

    coll.bind 'fetch', ->
      $spin.html $('<div id="loading-spinner" class="loading-spinner" />')

    bindScroll()
    bindLoaded()
    load()

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
