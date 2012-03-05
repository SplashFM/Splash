class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

  routes:
    'splashes/:id': 'splash'

  splash: (id) ->
    splash  = new Splash(id: id)
    splash.fetch().then =>
      content = new SingleSplash(app: @app, model: splash)

      @app.setPage content, Home

SingleSplash.Router = Router
