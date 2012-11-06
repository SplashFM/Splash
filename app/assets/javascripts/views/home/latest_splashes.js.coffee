class LatestSplashes extends Page.Content
  label: 'home.latest_splashes'

  initialize: ->
    super

    @app    = @options.app
    @sample = @options.sample
    @hashtag = @options.hashtag
    # force follower and user to be sent so we can get a 401 if that's the case
    @feed   = Feed.eventFeed this,
      Feed.emptiable @sample,
        filters:
          follower: if @sample == 'following' then @app.user.id or 0 else ''
          splashes: 1
          user:     if @sample == 'following' then @app.user.id or 0 else ''
          tags :     @hashtag 
        refresh:
          follower: if @sample == 'following' then @app.user.id or 0 else ''
          splashes: 1

    @routes = @app.routers.home.builder

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

window.Home.LatestSplashes = LatestSplashes
