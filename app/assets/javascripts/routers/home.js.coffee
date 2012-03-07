class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

    @builder = new Router.Builder(@app.user)

  routes:
    'top/tracks/:period/:sample': 'topTracks'
    'latest/:sample':             'latestSplashes'

  latestSplashes: (sample) ->
    @setPage new Home.LatestSplashes
      app:    @app
      sample: sample

  topTracks: (period = '7d', sample = @builder.defaultSample()) ->
    @setPage new Home.TopTracks
      app:    @app
      period: period
      sample: sample

  setPage: (content) ->
    if @app.current?.constructor == Home
      @app.setContent content
    else
      @app.setPage new Home(content: content, app: @app)

class Router.Builder
  constructor: (user) ->
    @user = user

  defaultSample: ->
    if @user.isNew() then 'everyone' else 'following'

  topTracks: (period = '7d', sample = @defaultSample()) ->
    "top/tracks/#{period}/#{sample}"

  latestSplashes: (sample = @defaultSample()) ->
    "latest/#{sample}"

Home.Router = Router
