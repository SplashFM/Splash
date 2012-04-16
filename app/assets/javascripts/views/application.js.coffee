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

    @_initializeTransientManagement()
    @_initializeAnalytics()

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

    @trigger 'tutorial:show'

    @tutorial.show()

  _clearHighlight: ->
    @$('#navigation li').removeClass 'current-page'

  _highlightPage: (page) =>
    @_clearHighlight()
    @$("#navigation li.navigation-#{page}").addClass 'current-page'

  _initializeAllResultsSearch: ->
    new Searchable(el: @el, $container: $(Page.Content::main)).render()

  _initializeAnalytics: ->
    Backbone.history.on 'route', ->
      url = Backbone.history.getFragment()
      _gaq.push ['_trackPageview', "/#{url}"]

    $('body').bind 'splash:splash splash:quick splash:resplash', (_, data) ->
      path = e.type.replace(':', '/')
      _gaq.push ['_trackPageview', '/actions/splash']
      _gaq.push ['_trackPageview', "/actions/#{path}"]

    $('body').bind 'upload:complete', (_, data) ->
      _gaq.push ['_trackPageview', '/actions/upload']

    $('body').bind 'follow unfollow', (e) ->
      _gaq.push ['_trackPageview', "/actions/#{e.type}"]

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

  _initializeTransientManagement: ->
    Backbone.history.on 'route', => @search.hide()
    Backbone.history.on 'route', => @$('div.tooltip').remove()
    Backbone.history.on 'route', => $.fancybox.close()

    @on 'tutorial:show', => $.fancybox.close()

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
       $t.attr('href')[0] == '#' or
       $t.attr('href').match /^http:/ then return

    e.preventDefault();

    Backbone.history.navigate $t.attr('href'), trigger: true

class EndlessScroll extends Backbone.View
  initialize: ->
    $(document).endlessScroll({callback: @triggerScroll});

  triggerScroll: => @trigger 'scroll'

window.Application = Application
