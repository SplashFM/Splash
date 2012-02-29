class Application extends Backbone.View
  el: 'body'

  events:
    'click a': '_routeLink'

  initialize: ->
    @userID       = @options.userID
    @userNickname = @options.userNickname

    @_initializeRoutes()

  _initializeRoutes: ->
    new Application.Router

    Backbone.history.start({pushState: true})

  _routeLink: (e) ->
    $t = $(e.target)

    if not $t.is('a') or
       not $t.attr('href') or
       $t.attr('href') in ['#', ''] or
       $t.attr('href')[0] == '/' then return

    e.preventDefault();

    Backbone.history.navigate $t.attr('href'), trigger: true

window.Application = Application
