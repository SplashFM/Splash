class Follows extends Backbone.View
  className: 'user-follows'

  initialize: ->
    @user = @options.user

  render:  ->
    @$el.html JST['profile/follows'](user: @user.toJSON())

    @$('.tabs').tabs()

    this

window.Profile.Follows = Follows
