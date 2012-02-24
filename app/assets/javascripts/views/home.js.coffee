class Home extends Page
  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  Home.Router.routes.topTracks()
        label: 'home.top_splashes'
      }, {
        href:  Home.Router.routes.latestSplashes()
        label: 'home.latest_splashes'}]
      active: content.label)

  renderSidebar: ($container) ->
    suggestedSplashers = new SuggestedSplashersView(followerID: @app.user.id)

    $container.append suggestedSplashers.render().el

window.Home = Home
