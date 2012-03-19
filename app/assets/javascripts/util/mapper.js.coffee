window.Mapper = (collection, pluckFunc) ->
  at: (index, callback) ->
    i = collection.at index, (item) ->
      if callback? then callback pluckFunc(item)

    if i? then pluckFunc(i)
