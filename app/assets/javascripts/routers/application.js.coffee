class Router extends Backbone.Router
  routes:
    '':    'default'
    '_=_': 'default'

  default: ->
    Backbone.history.navigate(Home.Router.routes.topTracks(), trigger: true)

Application.Router = Router