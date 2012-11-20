class HashTagView extends Backbone.View
  className: 'hashtags-widgets'

  initialize: ->
    @user = @options.user
    @sample = @options.sample
    params = data: 
             follower: if @options.sample == 'following' then @user.id or 0 else ''
             user: if @sample == 'following' then @user.id or 0 else ''

    @collection = new HashTags
    @collection.fetch params
          
    @collection.bind 'reset', this.render, this
     
  render:  -> 
  #TODO: Use template in app/views to better load
          
    @$el.html JST['shared/hashtags']({tags: @tags_name(), sample: @sample})
   
   # @$el.html $.tmpl(@template, {tags: @tags_name(), sample: @sample})
   
   # TODO: USE JSCROLL in better way,  
   # $('#hashtag_list').jScrollPane()
   # $('.jspVerticalBar').css({ 'display': 'none' })
    
    hashtagSearch = new HashtagSearch {el: this.$('input.hashtag_field'), parent: this.el }

    this
  
  tags_name: ->
    @list = []
    for t in @collection.models
      @list.push t.toJSON().value.toUpperCase()
    @list  

window.Profile.HashTagView = HashTagView

#$ ->
#  HashTagView::template = $('#tmpl-hashtag-list').template();

