class Notifiable extends Backbone.View
  events:
    'notification:expand'  : 'notificationExpanded'
    'notification:collapse': 'notificationCollapsed'
    'notification:loaded'  : 'checkSize'

  initialize: ->
    @$container = @options.$container
    @eventAgg   = @options.eventAgg
    @allResults = new Notification.AllResults(eventAgg: @eventAgg)
    

  checkSize: ->
    offs = @allResults.$el.offset()
    arh  = offs.top + @allResults.$el.height()

    if @$el.height() < arh
      @$el.height(@$el.height() + arh - @$el.height())
    
  render: ->
    @allResults.render()

  notificationCollapsed: ->

  notificationExpanded: ->
    @eventAgg.trigger('trackSearch:close')
    @showAllResults()

  showAllResults: () ->
    @$('.events-wrap').prepend(@allResults.el)
    @allResults.load()

window.Notifiable = Notifiable
