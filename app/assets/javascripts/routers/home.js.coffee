class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

    @builder = new Router.Builder

  routes:
    'top/tracks/:period/:sample': 'topTracks'
    'latest/:sample':             'latestSplashes'

  latestSplashes: (sample) ->
    @setPage new Home.LatestSplashes
      app:    @app
      sample: sample

  topTracks: (period = '7d', sample = 'following') ->
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
  topTracks: (period = '7d', sample = 'following') ->
    "top/tracks/#{period}/#{sample}"

  latestSplashes: (sample = 'following') ->
    "latest/#{sample}"

Home.Router = Router
