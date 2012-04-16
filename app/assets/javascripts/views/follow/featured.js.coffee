class Featured extends Page.Content
  label: 'follow.featured_splashers'

  initialize: ->
    super

    @sample = @options.sample

    @feed   = Feed.feed this,
      Feed.emptiable @sample,
        collection: new UserList
        className:  'splashboard-items live-feed'
        filters:
          featured: true
        newItem:    (i) -> new Follow.TopSplashers.User(model: i)
        allLoaded:  $("<p><a href='mailto:get@splash.fm'>get@splash.fm</a> " +
                      "to become a Featured Splasher</p>")

    @routes = Follow.Router.routes

Follow.Featured = Featured
