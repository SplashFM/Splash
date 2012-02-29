class Sidebar extends Backbone.View
  id: 'side-bar'

  initialize: ->
    @app     = @options.app
    @user    = @options.user

    @widgets = []

  render: ->
    # taking implementation of waternums into account
    vcard = Profile.Vcard.get(@app, @user)
    @$el.append vcard.el
    vcard.render()

    _(@widgets).each (w) => @$el.append w.render().el

    this

window.Sidebar = Sidebar