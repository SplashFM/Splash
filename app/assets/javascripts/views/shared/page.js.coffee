class Page extends Backbone.View
  el:               '#main'
  streamWrapClass:  'left'
  sidebarWrapClass: 'right'

  initialize: ->
    @app     = @options.app
    @content = @options.content
    @user    = @options.user or @app.user

    @sidebar = new Sidebar(app: @app, user: @user, className: @sidebarClass, profile: @options.profile)

  placeContent: (content) ->
    @$('#stream-wrap').html content.el

  remove: ->
    @content.remove()
    @sidebar.remove()

  render: ->
    @$el.attr 'class', @className

    @placeContent @content

    @renderSidebar @sidebar
    @renderTop     @content
    @renderContent @content

    @runPlugins()

    this

  renderContent: (content) ->
    @$('#stream-wrap').attr 'class', @streamWrapClass

    @content.render()

  renderSidebar: (sidebar) ->
    @$('#side-bar-wrap').attr 'class', @sidebarWrapClass

    @$('#side-bar-wrap').prepend sidebar.render().el

    name = sidebar.$('h2.actor_name').text()

    if name.length > 17
      sidebar.$('h2.actor_name').html(name.substr(0, 15) + "&hellip;")

  renderTop:     (content) ->

  runPlugins: ->
    @$('.fancybox').fancybox Scaphandrier.Fancybox.params.customizations
    @$('.fancybox-large').fancybox Scaphandrier.Fancybox.Large.params.customizations

  setContent: (content) ->
    if @content then @content.remove()

    @content = content

    @placeContent @content

    @renderTop     @content
    @renderContent @content


class Content extends Backbone.View
  id:       'stream-feed'
  main:     '.events-wrap'
  top:      '.streamfeed-top'
  spinner: '.loading-spinner-container'

  initialize: ->
    @app   = @options.app

    @$el.html(JST['shared/content']())

    @$top  = @$(@top)
    @$main = @$(@main)

  render: ->
    @renderTop  @$top.find('.feed-settings-tabs')
    @renderMain @$main

    this

  renderTop:  ($top)  ->
  renderMain: ($main) ->


Page.Content = Content

window.Page = Page
