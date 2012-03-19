window.Paginate = (collection, elemsPerPage, fetchData) ->
  lastLength   = undefined
  data         = _({}).extend(fetchData, page: 0)
  elemsPerPage = elemsPerPage or 10

  collection.bind "reset", -> data.page = 1

  _(
    collection: ->
      collection

    fetchNext: (n = 1) ->
      lastLength = collection.length

      @trigger "fetch"

      d = _.extend({}, data, page: data.page + 1)

      collection.fetch
        add:     true
        data:    d
        success: =>
          @loaded()

          n = n - 1

          if n > 0 then @fetchNext n
        error:   => @trigger "paginate:error"

    hasNext: ->
      not lastLength? or collection.length == (lastLength + elemsPerPage)

    loaded: =>
      data.page = data.page + 1

      @trigger "loaded"

    refetch: ->
      collection.reset()

      data.page = 0

      @fetchNext()

  ).extend Backbone.Events