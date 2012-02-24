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
    $main.append EventFeed
      follower: if @sample == 'following' then @app.user.id else ''
      splashes: 1
      user:     if @sample == 'following' then @app.user.id else ''

window.Home.LatestSplashes = LatestSplashes
