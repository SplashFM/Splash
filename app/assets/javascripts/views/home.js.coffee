class Home extends Page
  className: 'home index'

  renderTop: (content) ->
    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  @app.routers.home.builder.topTracks()
        label: 'home.top_splashes'
      }, {
        href:  @app.routers.home.builder.latestSplashes()
        label: 'home.latest_splashes'}]
      active: content.label)

  renderSidebar: (sidebar) ->
    super

    if @app.user.isNew()
      sidebar.add new TemplateView
        className: 'facepile'
        template:  JST['home/facepile']
      sidebar.add new TemplateView
        className: 'social-buttons'
        template:  JST['home/social_buttons']
      sidebar.add new TemplateView
        className: 'in-the-press'
        template:  JST['home/in_the_press']
    else
      sidebar.add new SuggestedSplashersView(followerID: @app.user.id)
      sidebar.add new InviteUserView

window.Home = Home
