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
    @setPage new Follow.Friends(app: @app)

  topSplashers: (sample = 'following') ->
    @setPage new Follow.TopSplashers
      app:    @app
      sample: sample

  setPage: (content) ->
    if @app.current?.constructor == Follow
      @app.setContent content
    else
      @app.setPage new Follow(content: content, app: @app)


Follow.Router = Router
