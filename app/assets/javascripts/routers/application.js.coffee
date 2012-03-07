class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

  routes:
    '':    'default'
    '_=_': 'default'

  default: ->
    Backbone.history.navigate(Home.Router.routes.topTracks(), trigger: true)

Application.Router = Router