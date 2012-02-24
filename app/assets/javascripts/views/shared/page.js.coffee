class Page extends Backbone.View
  el: '#main'

  initialize: ->
    @$sidebar = @$('#side-bar .var')

    @app     = @options.app
    @content = @options.content

  remove: ->
    @content.remove()

    @removeSidebar()

  removeSidebar: ->
    @$sidebar.empty()

  render: ->
    @renderTop     @content
    @renderContent @content
    @renderSidebar @$sidebar

    this

  renderContent: (content)    -> @$('#stream-wrap').html content.render().el
  renderSidebar: ($container) ->
  renderTop:     (content)    ->

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
