class Searchable extends Backbone.View
  events:
    'userSearch:expand'   : 'searchExpanded'
    'userSearch:collapse' : 'searchCollapsed'
    'userSearch:loaded'   : 'checkSize'

  initialize: ->
    @$container = @options.$container
    @eventAgg   = @options.eventAgg
    @allResults = new User.AllResults(eventAgg: @eventAgg)

  checkSize: ->
    offs = @allResults.$el.offset()
    arh  = offs.top + @allResults.$el.height()

    if @$el.height() < arh
      @$el.height(@$el.height() + arh - @$el.height())
  
  render: ->
    @allResults.render()

  searchCollapsed: ->

  searchExpanded: (_, data) ->
    @eventAgg.trigger('notification:close')
    @eventAgg.trigger('trackSearch:close')
    @showAllResults(data.terms)
    
  showAllResults: (searchTerms) ->
    @$('.events-wrap').prepend(@allResults.el)
    @allResults.load(searchTerms)
    
 
window.UserSearchable = Searchable
