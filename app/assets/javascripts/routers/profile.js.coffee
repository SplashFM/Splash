class Router extends Backbone.Router
  @routes:
    profile: (nickname, section = 'splashes') ->
      "#{nickname}/#{section}"

  initialize: (opts) ->
    @app = opts.app

  routes:
    ':nickname':          'profile'
    ':nickname/:section': 'profile'

  profile: (nickname, section = 'splashes') ->
    if @app.current?.constructor == Profile and @app.current.user.get('nickname') == nickname
      @app.setContent new Profile.Content(app: @app, user: @app.current.user, section: section)
    else
      @setProfile nickname, section

  setProfile: (nickname, section) ->
    if nickname != @app.user.get('nickname')
      user = new User(id: nickname)
      user.fetch().then =>
        @setPage new Profile.Content(app: @app, user: user, section: section), user
    else
      @setPage new Profile.Content(app: @app, user: @app.user, section: section), @app.user

  setPage: (content, user) ->
    @app.setPage new Profile(app: @app, content: content, user: user, profile: true)


Profile.Router = Router
