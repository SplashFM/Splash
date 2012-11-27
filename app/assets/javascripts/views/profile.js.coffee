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

    sidebar.add new Profile.Follows(user: @user, full: true, isNew: @app.user.isNew())

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

    content.$top.find('.inner-nav-tabs li a').smartTruncation()
    content.$top.find('.inner-nav').append (new Profile.HashTagView({user: @app.user, sample: 'profile'})).render().el


class Profile.Content extends Page.Content
  initialize: ->
    super

    @section  = @options.section
    @user     = @options.user
    @hashtag  = @options.hashtag || ''
    @mention  = '@' + @user.get('nickname')
    @label    = if @section == 'mentions' then @mention else 'profile.my_splashes'

    if @app.user.isEqual(@user)
      refresh = false
    else
      refresh =
        follower: if @section == 'mentions' then @user.id else ''
        mentions: if @section == 'mentions' then 1 else ''
        splashes: if @section == 'splashes' then 1 else ''
        user:     @user.id
        tags:  @hashtag if @hashtag != ''
    @feed     = Feed.eventFeed this,
      filters:
        follower: if @section == 'mentions' then @user.id else ''
        mentions: if @section == 'mentions' then 1 else ''
        splashes: if @section == 'splashes' then 1 else ''
        user:     @user.id
        tags:  @hashtag if @hashtag != ''

      refresh:    refresh
      update:     @app.user.isEqual(@user)

    @routes   = Profile.Router.routes

window.Profile = Profile
