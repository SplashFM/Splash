class Router extends Backbone.Router
  @routes:
    topSplashers: (sample = 'following') ->
      "top/splashers/#{sample}"
    friends:  -> "friends"

  initialize: (opts) ->
    @app = opts.app

  routes:
    'follow':                'topSplashers'
    'friends':               'friends'
    'top/splashers/:sample': 'topSplashers'

  friends: ->
    @app.setPage new Follow.Friends(app: @app), Follow

  topSplashers: (sample = 'following') ->
    content = new Follow.TopSplashers
      app:    @app
      sample: sample

    @app.setPage content, Follow

Follow.Router = Router
