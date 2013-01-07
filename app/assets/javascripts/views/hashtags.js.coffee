class HashTagView extends Backbone.View
  className: 'hashtags-widgets'

  initialize: ->
    @user = @options.user
    @sample = @options.sample
    @section = @options.section || ''
    @MAX_LEN = 25
    params = data: 
             follower: if @options.sample == 'following' then @user.id or 0 else ''
             user: if (@sample == 'following' or @sample == 'profile')  then @user.id or 0 else ''

    @collection = new HashTags
    @collection.fetch params
          
    @collection.bind 'reset', this.render, this
     
  render:  -> 
    tags = @tags_name()
    @$el.html JST['shared/hashtags']({tags: tags.list, sample: @sample, user: @user, section: @section })
    
    if tags.size > @MAX_LEN
      $("#hashtag-ul").jcarousel()
      
    hashtagSearch = new HashtagSearch {el: this.$('input.hashtag_field'), parent: this.el, user: @user, sample: @sample }
    
    this
      
  tags_name: ->
    @len = 0
    @list = []
    for t in @collection.models
      val = t.toJSON().value
      @len = @len + val.length
      @list.push val.toUpperCase()
    {list: @list, size: @len}  

window.Profile.HashTagView = HashTagView
