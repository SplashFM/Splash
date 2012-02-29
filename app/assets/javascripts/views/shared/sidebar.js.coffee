class Sidebar extends Backbone.View
  id: 'side-bar'

  initialize: ->
    @app     = @options.app
    @user    = @options.user

    @widgets = []

  render: ->
    @$el.append Profile.Vcard.get(@app, @user).render().el

    _(@widgets).each (w) => @$el.append w.render().el

    this

window.Sidebar = Sidebar