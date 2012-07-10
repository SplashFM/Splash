class Searchable extends Backbone.View
  events:
    'search:expand'   : 'searchExpanded'
    'search:collapse' : 'searchCollapsed'
    'search:loaded'   : 'checkSize'

  initialize: ->
    @$container = @options.$container
    @eventAgg   = @options.eventAgg
    @allResults = new TrackSearch.AllResults(eventAgg: @eventAgg)


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
    @showAllResults(data.terms)
    
  showAllResults: (searchTerms) ->
    @$('.events-wrap').prepend(@allResults.el)
    @allResults.load(searchTerms)

window.Searchable = Searchable
