class Application extends Backbone.View
  el: 'body'

  events:
    'click a':                           '_routeLink'
    'click [data-widget = "first-aid"]': 'showTutorial'
    'click .show-tutorial':              'showTutorial'
    'upload:complete':                   'removeUpload'

  initialize: ->
    @user          = @options.user
    @facebookAppID = @options.facebookAppID

    @_initializeFacebook()
    @_initializeSearch()
    @_initializeAllResultsSearch()
    @_initializeNotifications()
    @_initializeScroll()
    @_initializePlayer()
    @_initializeUpload()
    @_initializePlugins()

  initializeRoutes: ->
    @routers = {}

    @routers.profile     = new Profile.Router(app: this)
    @routers.application = new Application.Router(app: this)
    @routers.home        = new Home.Router(app: this)
    @routers.follow      = new Follow.Router(app: this)
    @routers.splash      = new SingleSplash.Router(app: this)

    @routers.profile.bind 'all', (_, nickname) =>
      if nickname == @user.get('nickname')
        @_highlightPage 'profile'
      else
        @_clearHighlight()
    @routers.home.bind    'all', => @_highlightPage 'home'
    @routers.follow.bind  'all', => @_highlightPage 'follow'
    @routers.splash.bind  'all', => @_clearHighlight()

    Backbone.history.start({pushState: true})

    @_initializeTooltipManagement()
    @_initializeSearchMananagement()

  removeUpload: ->
    @upload.remove()

  setContent: (content) -> @current.setContent content

  setPage: (page) ->
    if @current then @current.remove()

    @current = page.render()

  showTutorial: ->
    unless @tutorial
      @tutorial = new Tutorial

      @$el.append(@tutorial.shadeEl).append(@tutorial.el)

    @tutorial.show()

  _clearHighlight: ->
    @$('#navigation li').removeClass 'current-page'

  _highlightPage: (page) =>
    @_clearHighlight()
    @$("#navigation li.navigation-#{page}").addClass 'current-page'

  _initializeAllResultsSearch: ->
    new Searchable(el: @el, $container: $(Page.Content::main)).render()

  _initializeFacebook: ->
    FB.init appId: @facebookAppID, xfbml: true, cookie: true

  _initializeNotifications: ->
      new BaseApp.Notifications el: $('[data-widget = "notifications"]')

  _initializePlayer: ->
    @player      = new Player
    @mediaCenter = new MediaCenter(el: @el, player: @player)

  _initializePlugins: ->
    @$('.fancybox-large').fancybox Scaphandrier.Fancybox.Large.params.customizations
    @$('.fancybox').fancybox Scaphandrier.Fancybox.params.customizations

  _initializeScroll: ->
    @scroll = new EndlessScroll

  _initializeSearch: ->
    new BaseApp.GlobalSearch
    @search = new BaseApp.UserSearch
    new BaseApp.TrackSearch

  _initializeSearchMananagement: ->
    Backbone.history.on 'route', => @search.hide()

  _initializeTooltipManagement: ->
    Backbone.history.on 'route', => @$('div.tooltip').remove()

  _initializeUpload: ->
    $w       = @$('[data-widget = "global-search"]')
    progress = new Upload.Feedback.Progress(el: $w.get(0), $progress: $w)

    @upload  = new Upload(el: $w.get(0), progress: progress)

  _routeLink: (e) ->
    $t = $(e.target).closest('a')

    if not $t.is('a') or
       not $t.attr('href') or
       $t.attr('href') in ['#', ''] or
       $t.attr('href')[0] == '/' or
       $t.attr('href').match /^http:/ then return

    e.preventDefault();

    Backbone.history.navigate $t.attr('href'), trigger: true

class EndlessScroll extends Backbone.View
  initialize: ->
    $(document).endlessScroll({callback: @triggerScroll});

  triggerScroll: => @trigger 'scroll'


window.Application = Application
