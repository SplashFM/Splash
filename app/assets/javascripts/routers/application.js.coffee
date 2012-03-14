class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

  routes:
    '':    'default'
    '_=_': 'default'

  default: ->
    builder = if @app.user.isNew()
                @app.routers.home.builder.topTracks()
              else
                @app.routers.home.builder.latestSplashes()

    Backbone.history.navigate(builder, trigger: true)

Application.Router = Router