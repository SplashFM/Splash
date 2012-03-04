class Profile.Vcard extends Backbone.View
  @get: (app, user) ->
    new Profile.Vcard(user: user, editable: user == app.user)

  className: 'user-vcard'

  initialize: ->
    @user     = @options.user
    @editable = @options.editable

  render: ->
    @$el.html JST['profile/vcard'](user: @user.toJSON(), editable: @editable)

    SPLASH.Widgets.waterNums @$('.waterNum')

    this
