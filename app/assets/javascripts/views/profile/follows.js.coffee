class Follows extends Backbone.View
  className: 'user-follows'

  initialize: ->
    @user = @options.user
    @full = @options.full
    @isNew = @options.isNew

  render:  ->
    @$el.html JST['profile/follows'](user: @user.toJSON(), full: @full, isNew: @isNew)

    if @full then @$('.tabs').tabs()

    this

window.Profile.Follows = Follows
