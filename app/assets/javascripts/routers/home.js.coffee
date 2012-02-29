class Router extends Backbone.Router
  @routes:
    topTracks: (period = '7d', sample = 'following') ->
      "top/tracks/#{period}/#{sample}"
    latestSplashes: (sample = 'following') ->
      "latest/#{sample}"

  initialize: (opts) ->
    @app = opts.app

  routes:
    'top/tracks/:period/:sample': 'topTracks'
    'latest/:sample':             'latestSplashes'

  latestSplashes: (sample) ->
    content = new Home.LatestSplashes
      app:    @app
      sample: sample

    @_renderHome content

  topTracks: (period, sample) ->
    content = new Home.TopTracks
      app:    @app
      period: period
      sample: sample

    @_renderHome content

  _renderHome: (content) ->
    @app.setPage content, Home

Home.Router = Router
