window.Paginate = (collection, elemsPerPage, fetchData) ->
  lastLength   = undefined
  data         = _({}).extend(fetchData, page: 0)
  elemsPerPage = elemsPerPage or 10

  collection.bind "reset", -> data.page = 1

  _(
    at: (index, callback) ->
      if index >= collection.length
        n = @pageFor(index) - data.page

        @fetchNext n, -> if callback? then callback collection.at(index)

        undefined
      else
        if callback? then callback collection.at(index)

        collection.at(index)

    collection: ->
      collection

    fetchNext: (n = 1, callback) ->
      lastLength = collection.length

      @trigger "fetch"

      d = _.extend({}, data, page: data.page + 1)

      collection.fetch
        add:     true
        data:    d
        success: =>
          @loaded()

          n = n - 1

          if n > 0
            @fetchNext n, callback
          else if callback?
            callback()
        error:   => @trigger "paginate:error"

    hasNext: ->
      not lastLength? or collection.length == (lastLength + elemsPerPage)

    loaded: =>
      data.page = data.page + 1

      @trigger "loaded"

    pageFor: (index) ->
      parseInt(index / elemsPerPage) + 1

    refetch: ->
      collection.reset()

      data.page = 0

      @fetchNext()

  ).extend Backbone.Events