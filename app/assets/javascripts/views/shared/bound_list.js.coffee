class BoundList extends Backbone.View
  tagName: 'ul'

  initialize: ->
    @collection.bind 'reset', @reset
    @collection.bind 'add', @addItem
    @collection.bind 'remove', @removeItem

  addItem: (item, _, details) =>
    index = details.index
    li    = @$el.children('li').eq(index).get(0)

    if li
      $(li).before @renderItem(item)
    else
      @appendItem item

  appendItem: (item) =>
    @$el.append @renderItem(item)

  indexOf: (item) ->
    @$el.children().index(item)

  removeItem: (_, _, details) =>
    @$el.children().last().remove()

  render: ->
    @collection.each @appendItem

    return this

  renderItem: (item) -> @newItem(item).render().el

  reset: =>
    @$el.empty()

    @render()

window.BoundList = BoundList
