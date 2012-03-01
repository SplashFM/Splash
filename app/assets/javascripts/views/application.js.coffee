class Application extends Backbone.View
  el: 'body'

  events:
    'click a':                           '_routeLink'
    'click [data-widget = "first-aid"]': 'showTutorial'

  initialize: ->
    @user = @options.user

    @_initializeVcard()
    @_initializeRoutes()
    @_initializeSearch()
    @_initializeNotifications()
    @_initializeScroll()

  setPage: (content, constructor, constructorArgs = {}) ->
    args = _(content: content, app: this).extend constructorArgs

    if @current
      if @current.constructor == constructor
        @current.setContent content
      else
        @current.remove()

        @current = new constructor(args).render()
    else
      @current = new constructor(args).render()

  showTutorial: ->
    unless @tutorial
      @tutorial = new Tutorial

      @$el.append(@tutorial.shadeEl).append(@tutorial.el)

    @tutorial.show()

  _initializeNotifications: ->
      new BaseApp.Notifications el: $('[data-widget = "notifications"]')

  _initializeRoutes: ->
    new Application.Router
    new Profile.Router(app: this)
    new Home.Router(app: this)

    Backbone.history.start({pushState: true})

  _initializeScroll: ->
    @scroll = new EndlessScroll

  _initializeSearch: ->
    new BaseApp.GlobalSearch
    new BaseApp.UserSearch

  _initializeVcard: ->
    @vcard = new Profile.Vcard(app: this, user: @user).render()

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
