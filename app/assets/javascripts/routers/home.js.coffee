class Router extends Backbone.Router
  @routes:
    topTracks: (period = '7d', sample = 'following') ->
      "top/tracks/#{period}/#{sample}"

  initialize: (opts) ->
    @app = opts.app

  routes:
    'top/tracks/:period/:sample': 'topTracks'

  topTracks: (period, sample) ->
    content = new Home.TopTracks
      app:    @app
      period: period
      sample: sample

    @_renderHome content

  _renderHome: (content) ->
    if @app.current
      if @app.current.constructor == Home
        @app.current.setContent content
      else
        @app.current.remove()

        @app.current = new Home(content: content, app: @app).render()
    else
      @app.current = new Home(content: content, app: @app).render()

Home.Router = Router
