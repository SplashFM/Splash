class Router extends Backbone.Router
  @routes:
    topSplashers: (sample = 'following') ->
      "top/splashers/#{sample}"

  initialize: (opts) ->
    @app = opts.app

  routes:
    'follow':                'topSplashers'
    'top/splashers/:sample': 'topSplashers'

  topSplashers: (sample = 'following') ->
    content = new Follow.TopSplashers
      app:    @app
      sample: sample

    @app.setPage content, Follow

Follow.Router = Router
