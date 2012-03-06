class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

  routes:
    '':    'default'
    '_=_': 'default'

  default: ->
    Backbone.history.navigate(@app.routers.home.builder.topTracks(), trigger: true)

Application.Router = Router