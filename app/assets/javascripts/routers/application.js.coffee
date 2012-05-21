class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

  routes:
    '':    'default'
    '_=_': 'default'

  default: ->
    builder = @app.routers.home.builder.topTracks()

    Backbone.history.navigate(builder, trigger: true)

Application.Router = Router
