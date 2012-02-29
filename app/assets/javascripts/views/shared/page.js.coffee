class Page extends Backbone.View
  el: '#main'

  initialize: ->
    @app     = @options.app
    @content = @options.content
    @user    = @options.user or @app.user

    @sidebar = new Sidebar(app: @app, user: @user)

  remove: ->
    @content.remove()
    @sidebar.remove()

  render: ->
    @renderTop     @content
    @renderContent @content
    @renderSidebar @sidebar

    this

  renderContent: (content) -> @$('#stream-wrap').html content.render().el
  renderSidebar: (sidebar) -> @$('#side-bar-wrap').prepend sidebar.render().el
  renderTop:     (content) ->

  setContent: (content) ->
    if @content then @content.remove()

    @content = content

    @renderTop     @content
    @renderContent @content

class Content extends Backbone.View
  id:   'stream-feed'
  main: '.events-wrap'
  top:  '.streamfeed-top'

  initialize: ->
    @app   = @options.app

    @$el.html(JST['shared/content']())

    @$top  = @$(@top)
    @$main = @$(@main)

  render: ->
    @renderTop  @$top.find('.feed-settings-tabs')
    @renderMain @$main

    this

Page.Content = Content

window.Page = Page
