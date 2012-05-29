class Follow extends Page
  className: 'follow'

  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  Follow.Router.routes.featured()
        label: 'follow.featured_splashers'
      }, {
        href:  Follow.Router.routes.topSplashers()
        label: 'follow.top_splashers'
      }, {
        href:  Follow.Router.routes.friends()
        label: 'follow.friends'
      }]
      active: content.label)

  renderSidebar: (sidebar) ->
    super

    sidebar.add new SuggestedSplashersView(followerID: @app.user.id)
    sidebar.add new InviteUserView
    sidebar.add new TemplateView
      className: 'social-buttons'
      template:  JST['home/social_buttons']
      args: @app.user.toJSON()

window.Follow = Follow
