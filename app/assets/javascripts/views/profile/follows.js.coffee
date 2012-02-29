class Follows extends Backbone.View
  className: 'user-follows'

  initialize: ->
    @user = @options.user

  render:  ->
    @$el.html JST['profile/follows'](user: @user)

    @$('.tabs').tabs()
    @$('.fancybox').fancybox Scaphandrier.Fancybox.params.customizations

    this

window.Profile.Follows = Follows
