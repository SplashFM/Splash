class Follows extends Backbone.View
  className: 'user-follows'

  initialize: ->
    @user = @options.user
    @full = @options.full

  render:  ->
    @$el.html JST['profile/follows'](user: @user.toJSON(), full: @full)

    if @full then @$('.tabs').tabs()

    this

window.Profile.Follows = Follows
