class Profile extends Page
  className: 'users show'
  streamWrapClass: 'right'
  sidebarWrapClass: 'left'
  sidebarClass:     'users show'

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
    $main.append EventFeed
      follower: if @section == 'mentions' then @app.user.id else ''
      mentions: if @section == 'mentions' then 1 else ''
      splashes: if @section == 'splashes' then 1 else ''
      user:     @app.user.id

window.Profile = Profile