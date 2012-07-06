class Notifiable extends Backbone.View
  events:
    'notification:expand':   'notificationExpanded'
    'notification:collapse': 'notificationCollapsed'
    'notification:loaded':   'checkSize'

  initialize: ->
    console.log('0. initialize Notifiable')
    @$container = @options.$container
    @allResults = new Notification.AllResults()

  checkSize: ->
    offs = @allResults.$el.offset()
    arh  = offs.top + @allResults.$el.height()

    if @$el.height() < arh
      @$el.height(@$el.height() + arh - @$el.height())

  render: ->
    @allResults.render()

  notificationCollapsed: ->

  notificationExpanded: ->
    #@trigger('close:track')
    @showAllResults()

  showAllResults: () ->
    console.log('2. In showAllResults(): notificationExpand triggered')
    @$('.events-wrap').find('.all-results').remove()
    @$('.events-wrap').prepend(@allResults.el)
    
    @allResults.load()

window.Notifiable = Notifiable
