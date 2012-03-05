class Page extends Backbone.View
  el:               '#main'
  streamWrapClass:  'left'
  sidebarWrapClass: 'right'

  initialize: ->
    @app     = @options.app
    @content = @options.content
    @user    = @options.user or @app.user

    @sidebar = new Sidebar(app: @app, user: @user, className: @sidebarClass)

  remove: ->
    @content.remove()
    @sidebar.remove()

  render: ->
    @$el.attr 'class', @className

    @renderTop     @content
    @renderContent @content
    @renderSidebar @sidebar

    @runPlugins()

    this

  renderContent: (content) ->
    @$('#stream-wrap').attr 'class', @streamWrapClass

    @$('#stream-wrap').html content.render().el

  renderSidebar: (sidebar) ->
    @$('#side-bar-wrap').attr 'class', @sidebarWrapClass

    @$('#side-bar-wrap').prepend sidebar.render().el

  renderTop:     (content) ->

  runPlugins: ->
    @$('.fancybox').fancybox Scaphandrier.Fancybox.params.customizations
    @$('.fancybox-large').fancybox Scaphandrier.Fancybox.Large.params.customizations

  setContent: (content) ->
    if @content then @content.remove()

    @content = content

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
