class Searchable extends Backbone.View
  events:
    'search:expand':   'searchExpanded'
    'search:collapse': 'searchCollapsed'
    'search:loaded':   'checkSize'

  initialize: ->
    @$container = @options.$container
    @allResults = new TrackSearch.AllResults()

  checkSize: ->
    offs = @allResults.$el.offset()
    arh  = offs.top + @allResults.$el.height()

    if @$el.height() < arh
      @$el.height(@$el.height() + arh - @$el.height())

  render: ->
    @allResults.render()

  searchCollapsed: ->

  searchExpanded: (_, data) ->
    #@$el.trigger('close:notification')
    @showAllResults(data.terms)
    
  showAllResults: (searchTerms) ->
    #@$('.events-wrap').find('.all-results').remove()
    
    @$('.events-wrap').prepend(@allResults.el)

    @allResults.load(searchTerms)

window.Searchable = Searchable
