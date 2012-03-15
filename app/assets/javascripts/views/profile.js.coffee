class Profile extends Page
  className: 'users show'
  streamWrapClass: 'right'
  sidebarWrapClass: 'left'
  sidebarClass:     'users show'

  initialize: ->
    super

    @user = @options.user

  renderSidebar: (sidebar) ->
    super

    sidebar.add new Profile.Follows(user: @user, full: true)

  renderTop: (content) ->
    content.$top.append(JST['shared/top']())


class Profile.Content extends Page.Content
  initialize: ->
    super

    @section  = @options.section
    @user     = @options.user
    @feed     = Feed.eventFeed this,
      follower: if @section == 'mentions' then @user.id else ''
      mentions: if @section == 'mentions' then 1 else ''
      splashes: if @section == 'splashes' then 1 else ''
      user:     @user.id

    @routes   = Profile.Router.routes

  renderTop: ($top) ->
    $top.append JST['profile/search']()
    @trackSearch = new TrackSearch el: @$('[data-widget = "track-search"]')

    mention = '@' + @user.get('nickname')

    $top.append JST['shared/nav_list'](
      links: [{
        href:  @routes.profile(@user.get('nickname'), 'splashes')
        label: 'profile.my_splashes'
      }, {
        href:  @routes.profile(@user.get('nickname'), 'mentions')
        label: mention}]
      active:  if @section == 'mentions' then mention else 'profile.my_splashes'
    )

window.Profile = Profile