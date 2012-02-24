class Profile extends Page
  renderTop: (content) ->
    content.$top.append('<div class="feed-settings-tabs"></div>')

class Profile.Content extends Page.Content
  initialize: ->
    super

    @section  = @options.section
    @nickname = @options.nickname

    @routes   = Profile.Router.routes

  renderTop: ($top) ->
    $top.append JST['profile/search']()

    mention = '@' + @app.user.nickname

    $top.append JST['shared/nav_list'](
      links: [{
        href:  @routes.profile(@nickname, 'splashes')
        label: 'profile.my_splashes'
      }, {
        href:  @routes.profile(@nickname, 'mentions')
        label: mention}]
      active:  if @section == 'mentions' then mention else 'profile.my_splashes'
    )

  renderMain: ($main) ->
    o =
      follower: if @section == 'mentions' then @app.user.id else ''
      mentions: if @section == 'mentions' then 1 else ''
      splashes: if @section == 'splashes' then 1 else ''
      user:     @app.user.id
    p = Paginate(c = new EventList, 10, o)

    l = _(new BoundList(className: 'live-feed', collection: c)).extend
      newItem: (i) => new Feed.Splash(model: i, currentUserID: @app.user.id)

    p.fetchNext()

    $main.append l.el

window.Profile = Profile