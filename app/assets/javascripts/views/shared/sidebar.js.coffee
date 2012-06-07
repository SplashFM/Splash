class Sidebar extends Backbone.View
  id: 'side-bar'

  initialize: ->
    @app     = @options.app
    @user    = @options.user
    @showProfile = @options.profile

    @widgets = []

  add: (widget)->
    @$el.append widget.render().el

  render: ->
    if @showProfile || !@app.user.isNew()
      # taking implementation of waternums into account
      vcard = Profile.Vcard.get(@app, @user)
      @$el.append vcard.el
      vcard.render()

      if !@app.user.isNew()
        unless @app.user.isEqual(@user)
          @add new RelationshipView
            className: 'follow-container'
            model:     new Relationship(@user.get('relationship'))
            template:  $('#tmpl-profile-relationship').template()
    else
      @add new TemplateView
        className: 'login-box'
        template:  JST['home/login_box']

    @$el.append '<div class="contact-sep-shadow"></div>'

    this

window.Sidebar = Sidebar
