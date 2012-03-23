window.Paginate = (collection, elemsPerPage, fetchData) ->
  new Paginate(collection, elemsPerPage, fetchData)

class Paginate
  constructor: (collection, elemsPerPage, fetchData) ->
    @collection   = collection
    @elemsPerPage = elemsPerPage
    @data         = _({}).extend(fetchData, page: 0)

    @collection.bind 'reset', => @data.page = 1

  at: (index, callback) ->
    if index >= @collection.length
      @fetchNext @pageFor(index) - @data.page,
                 => if callback? then callback @collection.at(index)

      undefined
    else
      if callback? then callback @collection.at(index)

      @collection.at(index)

  fetchNext: (n = 1, callback) ->
    @lastLength = @collection.length

    data = _.extend({}, @data, page: @data.page + 1)

    @trigger "fetch"

    @collection.fetch
      add:     true
      data:    data
      success: =>
        @loaded()

        n = n - 1

        if n > 0
          @fetchNext n, callback
        else if callback?
          callback()
      error:   => @trigger "paginate:error"

  hasNext: ->
    not @lastLength? or @collection.length == (@lastLength + @elemsPerPage)

  loaded: ->
    @data.page = @data.page + 1

    @trigger "loaded"

  pageFor: (index) ->
    parseInt(index / @elemsPerPage) + 1

  refetch: ->
    @collection.reset()

    @data.page = 0

    @fetchNext()

_.extend(Paginate.prototype, Backbone.Events)
