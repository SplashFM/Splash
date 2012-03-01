class Follow extends Page
  className: 'follow'

  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  Follow.Router.routes.topSplashers()
        label: 'follow.top_splashers'
      }]
      active: content.label)

  renderSidebar: (sidebar) ->
    sidebar.widgets.push new SuggestedSplashersView(followerID: @app.user.id)

    super(sidebar)

window.Follow = Follow
