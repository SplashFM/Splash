class Router extends Backbone.Router
  routes:
    '' : 'default'

  default: ->
    Backbone.history.navigate('top/tracks/7d/following', trigger: true)

Application.Router = Router