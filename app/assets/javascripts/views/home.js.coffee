class Home extends Page
  className: 'home index'

  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  @app.routers.home.builder.latestSplashes()
        label: 'home.latest_splashes'
        },{
        href:  @app.routers.home.builder.topTracks()
        label: 'home.top_splashes'
      }]
      active: content.label)

  renderSidebar: (sidebar) ->
    super

    if @app.user.isNew()
      sidebar.add new TemplateView
        className: 'social-buttons'
        template:  JST['home/social_buttons']
        args: @app.user.toJSON()
      sidebar.add new TemplateView
        className: 'in-the-press'
        template:  JST['home/in_the_press']
    else
      if (@app.user.isEqual(@user))
        sidebar.add new TemplateView
          template: JST['profile/points']
          args: @user.toJSON()
      sidebar.add new SuggestedSplashersView(followerID: @app.user.id)
      sidebar.add new InviteUserView
      sidebar.add new TemplateView
        className: 'social-buttons'
        template:  JST['home/social_buttons']
        args: @app.user.toJSON()

window.Home = Home
