class Sidebar extends Backbone.View
  id: 'side-bar'

  initialize: ->
    @app     = @options.app
    @user    = @options.user

    @widgets = []

  add: (widget)->
    @$el.append widget.render().el

  render: ->
    if @app.user.isNew() then return this

    # taking implementation of waternums into account
    vcard = Profile.Vcard.get(@app, @user)
    @$el.append vcard.el
    vcard.render()

    unless @app.user.isEqual(@user)
      @add new RelationshipView
        className: 'follow-container'
        model:     new Relationship(@user.get('relationship'))
        template:  $('#tmpl-profile-relationship').template()

    @$el.append '<div class="contact-sep-shadow"></div>'

    this

window.Sidebar = Sidebar