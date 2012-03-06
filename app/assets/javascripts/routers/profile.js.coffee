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
    if nickname != @app.user.get('nickname')
      user = new User(id: nickname)
      user.fetch().then => @_setProfile user, section
    else
      @_setProfile @app.user, section

  _setProfile: (user, section) =>
    content = new Profile.Content(app: @app, user: user, section: section)

    @app.setPage content, Profile, user: user

Profile.Router = Router
