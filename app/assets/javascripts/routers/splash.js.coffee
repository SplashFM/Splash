class Router extends Backbone.Router
  @routes:
    splashes: (id) -> "splashes/#{id}"

  initialize: (opts) ->
    @app = opts.app

  routes:
    'splashes/:id': 'splash'
  splash: (id) ->
    splash  = new Splash(id: id)
    splash.fetch().then =>
      content = new SingleSplash(app: @app, model: splash)

      @app.setPage new Home(content: content, app: @app)

SingleSplash.Router = Router
