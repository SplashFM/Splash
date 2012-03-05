class Home extends Page
  className: 'home index'

  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  Home.Router.routes.topTracks()
        label: 'home.top_splashes'
      }, {
        href:  Home.Router.routes.latestSplashes()
        label: 'home.latest_splashes'}]
      active: content.label)

  renderSidebar: (sidebar) ->
    super

    sidebar.add new SuggestedSplashersView(followerID: @app.user.id)
    sidebar.add new InviteUserView

window.Home = Home
