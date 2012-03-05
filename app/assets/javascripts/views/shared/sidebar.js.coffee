class Sidebar extends Backbone.View
  id: 'side-bar'

  initialize: ->
    @app     = @options.app
    @user    = @options.user

    @widgets = []

  add: (widget)->
    @$el.append widget.render().el

  render: ->
    # taking implementation of waternums into account
    vcard = Profile.Vcard.get(@app, @user)
    @$el.append vcard.el
    vcard.render()
    @$el.append '<div class="contact-sep-shadow"></div>'

    this

window.Sidebar = Sidebar