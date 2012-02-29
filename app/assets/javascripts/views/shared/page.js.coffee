class Page extends Backbone.View
  el: '#main'

  initialize: ->
    @$sidebar = @$('#side-bar .var')

    @app     = @options.app
    @content = @options.content

  render: ->
    @renderTop     @content
    @renderContent @content
    @renderSidebar @$sidebar

    this

  renderContent: (content)    -> content.render()
  renderSidebar: ($container) ->
  renderTop:     (content)    ->


class Content extends Backbone.View
  el:   '#stream-feed'
  main: '.events-wrap'
  top:  '.streamfeed-top'

  initialize: ->
    @app   = @options.app

    @$top  = @$(@top)
    @$main = @$(@main)

  render: ->
    @renderTop  @$top.find('.feed-settings-tabs')
    @renderMain @$main

Page.Content = Content

window.Page = Page
