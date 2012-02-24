class LatestSplashes extends Page.Content
  label: 'home.latest_splashes'

  initialize: ->
    super

    @app    = @options.app
    @sample = @options.sample

    @routes = Home.Router.routes

  renderTop: ($top) ->
    $top.append JST['shared/nav_list'](
      links: [{
        href:  @routes.latestSplashes('following')
        label: 'top.following'
      }, {
        href:  @routes.latestSplashes('everyone')
        label: 'top.everyone'}]
      active:  "top.#{@sample}"
    )

  renderMain: ($main) ->
    o =
      follower: if @sample == 'following' then @app.userID else ''
      splashes: 1
      user:     if @sample == 'following' then @app.userID else ''
    p = Paginate(c = new EventList, 10, o)

    l = _(new BoundList(className: 'live-feed', collection: c)).extend
      newItem: (i) => new Feed.Splash(model: i, currentUserID: @app.userID)

    p.fetchNext()

    $main.append l.el


window.Home.LatestSplashes = LatestSplashes
