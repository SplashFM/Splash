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
    content = new Profile.Content(app: @app, nickname: nickname, section: section)

    @app.setPage content, Profile

Profile.Router = Router
