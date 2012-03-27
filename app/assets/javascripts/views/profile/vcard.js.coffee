class Profile.Vcard extends Backbone.View
  @get: (app, user) ->
    new Profile.Vcard(app: app, user: user, editable: user.isEqual(app.user))

  className: 'user-vcard'

  initialize: ->
    @app      = @options.app
    @user     = @options.user
    @editable = @options.editable

  render: ->
    @$el.html JST['profile/vcard']
      superuser: @app.user.get('superuser')
      user:      @user.toJSON()
      editable:  @editable

    if @editable
      new Profile.Vcard.Tagline el: @$('.tag-line.edit'), model: @user

    SPLASH.Widgets.waterNums @$('.waterNum')

    this


class Profile.Vcard.Tagline extends Backbone.View
  initialize: ->
    @$el.editable @commitEdit,
      type:    'textarea'
      cancel:  I18n.t('jeditable.labels.cancel')
      submit:  I18n.t('jeditable.labels.submit')
      tooltip: I18n.t('jeditable.labels.tooltip')

  commitEdit: (tagline) =>
    @model.save tagline: tagline

    tagline
