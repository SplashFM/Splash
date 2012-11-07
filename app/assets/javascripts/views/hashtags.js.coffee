class HashTagView extends Backbone.View
  className: 'hashtags-widgets'

  initialize: ->
    @user = @options.user
    @sample = @options.sample
    params = data: 
             follower: if @options.sample == 'following' then @user.id or 0 else ''
             user: if @sample == 'following' then @user.id or 0 else ''

    @collection = new HashTags()
    @collection.fetch params
          
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
