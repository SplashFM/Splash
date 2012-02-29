class Follow extends Page
  className: 'follow'

  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  Follow.Router.routes.topSplashers()
        label: 'follow.top_splashers'
      }, {
        href:  Follow.Router.routes.friends()
        label: 'follow.friends'
      }]
      active: content.label)

  renderSidebar: (sidebar) ->
    sidebar.widgets.push new SuggestedSplashersView(followerID: @app.user.id)
    sidebar.widgets.push new InviteUserView

    super(sidebar)

window.Follow = Follow
