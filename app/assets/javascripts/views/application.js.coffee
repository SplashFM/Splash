class Application extends Backbone.View
  el: 'body'

  events:
    'click a':                           '_routeLink'
    'click [data-widget = "first-aid"]': 'showTutorial'

  initialize: ->
    @user = @options.user

    @_initializeRoutes()
    @_initializeScroll()

  showTutorial: ->
    unless @tutorial
      @tutorial = new Tutorial

      @$el.append(@tutorial.shadeEl).append(@tutorial.el)

    @tutorial.show()

  _initializeRoutes: ->
    new Application.Router
    new Profile.Router(app: this)
    new Home.Router(app: this)

    Backbone.history.start({pushState: true})

  _initializeScroll: ->
    @scroll = new EndlessScroll

  _routeLink: (e) ->
    $t = $(e.target)

    if not $t.is('a') or
       not $t.attr('href') or
       $t.attr('href') in ['#', ''] or
       $t.attr('href')[0] == '/' then return

    e.preventDefault();

    Backbone.history.navigate $t.attr('href'), trigger: true


class EndlessScroll extends Backbone.View
  initialize: ->
    $(document).endlessScroll({callback: @triggerScroll});

  triggerScroll: => @trigger 'scroll'


window.Application = Application
