class BoundList extends Backbone.View
  tagName: 'ul'

  initialize: ->
    @collection.bind 'reset', @reset
    @collection.bind 'add', @addItem

  addItem: (item) =>
    @$el.append @renderItem(item)

  render: ->
    @collection.each(@addItem)

    return this

  renderItem: (item) -> @newItem(item).render().el

  reset: =>
    @$el.empty()

    @render()

window.BoundList = BoundList
