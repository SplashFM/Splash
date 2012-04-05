class Router extends Backbone.Router
  @routes:
    topSplashers: (sample = 'following') ->
      "top/splashers/#{sample}"
    friends:  -> "friends"
    featured: -> "featured"

  initialize: (opts) ->
    @app = opts.app

  routes:
    'featured':              'featured'
    'follow':                'topSplashers'
    'friends':               'friends'
    'top/splashers/:sample': 'topSplashers'

  friends: ->
    @setPage new Follow.Friends(app: @app)

  topSplashers: (sample = 'everyone') ->
    @setPage new Follow.TopSplashers
      app:    @app
      sample: sample

  featured: ->
    @setPage new Follow.Featured(app: @app)

  setPage: (content) ->
    if @app.current?.constructor == Follow
      @app.setContent content
    else
      @app.setPage new Follow(content: content, app: @app)


Follow.Router = Router
