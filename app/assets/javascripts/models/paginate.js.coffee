window.Paginate = (collection, elemsPerPage, fetchData) ->
  lastLength   = undefined
  data         = _({}).extend(fetchData, page: 0)
  elemsPerPage = elemsPerPage or 10

  collection.bind "reset", -> data.page = 1

  _(
    collection: ->
      collection

    fetchNext: ->
      data.page  = data.page + 1
      lastLength = collection.length

      @trigger "fetch"

      collection.fetch
        add:     true
        data:    data
        success: @loaded
        error:   => @trigger "paginate:error"

    hasNext: ->
      not lastLength? or collection.length == (lastLength + elemsPerPage)

    loaded: =>
      @trigger "loaded"

    refetch: ->
      collection.reset()

      data.page = 0

      @fetchNext()

  ).extend Backbone.Events