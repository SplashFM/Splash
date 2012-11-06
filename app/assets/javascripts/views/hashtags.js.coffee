class HashTagView extends Backbone.View
  className: 'hashtags-widgets'

  initialize: (@sample = sample)->
    @collection = new HashTags()
    @collection.fetch({data: {sample:  @sample}})
    @collection.bind 'reset', this.render, this
    
  render:  ->         
    @$el.html JST['shared/hashtags']({tags: @tags_name(), sample: @sample})
    this
  
  tags_name: ->
    @list = []
    for t in @collection.models
      @list.push t.toJSON().value.toUpperCase()
    @list  

window.Profile.HashTagView = HashTagView
