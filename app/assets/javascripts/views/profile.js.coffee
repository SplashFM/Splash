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

    if (@app.user.isEqual(@user))
      sidebar.add new TemplateView
        template: JST['profile/points']
        args: @user.toJSON()

    sidebar.add new Profile.Follows(user: @user, full: true)

  renderTop: (content) ->
    routes  = Profile.Router.routes

    content.$top.append JST['shared/tabbed_top'](
      links: [{
        href:  routes.profile(@user.get('nickname'), 'splashes')
        label: 'profile.my_splashes'
      }, {
        href:  routes.profile(@user.get('nickname'), 'mentions')
        label: content.mention}]
      active:  content.label)


class Profile.Content extends Page.Content
  initialize: ->
    super

    @section  = @options.section
    @user     = @options.user
    @mention  = '@' + @user.get('nickname')
    @label    = if @section == 'mentions' then @mention else 'profile.my_splashes'

    @feed     = Feed.eventFeed this,
      follower: if @section == 'mentions' then @user.id else ''
      mentions: if @section == 'mentions' then 1 else ''
      splashes: if @section == 'splashes' then 1 else ''
      user:     @user.id

    @routes   = Profile.Router.routes

window.Profile = Profile