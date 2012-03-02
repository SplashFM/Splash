class Profile extends Page
  className: 'users show'
  streamWrapClass: 'right'
  sidebarWrapClass: 'left'
  sidebarClass:     'users show'

  renderSidebar: (sidebar) ->
    sidebar.widgets.push new Profile.Follows(user: @app.user)

    super

  renderTop: (content) ->
    content.$top.append(JST['shared/top']())

class Profile.Content extends Page.Content
  initialize: ->
    super

    @section  = @options.section
    @nickname = @options.nickname

    @routes   = Profile.Router.routes

  renderTop: ($top) ->
    new Searchable(el: @el, top: $top).render()

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
    $main.append @eventFeed
      follower: if @section == 'mentions' then @app.user.id else ''
      mentions: if @section == 'mentions' then 1 else ''
      splashes: if @section == 'splashes' then 1 else ''
      user:     @app.user.id


class Searchable extends Backbone.View
  events:
    'search:expand':   'searchExpanded'
    'search:collapse': 'searchCollapsed'
    'search:loaded':   'checkSize'

  initialize: ->
    @$top = @options.top

    @allResults  = new TrackSearch.AllResults()

  checkSize: ->
    offs = @allResults.$el.offset()
    arh  = offs.top + @allResults.$el.height()

    if @$el.height() < arh
      @$el.height(@$el.height() + arh - @$el.height())

  render: ->
    @$top.append JST['profile/search']()

    @trackSearch = new TrackSearch el: @$('[data-widget = "track-search"]')
    @allResults.render()

  searchCollapsed: ->
    @trackSearch.enable()

  searchExpanded: (_, data) ->
    @trackSearch.disable()

    @showAllResults(data.terms)

  showAllResults: (searchTerms) ->
    @$('.events-wrap').prepend(@allResults.el)

    @allResults.load(searchTerms)

window.Profile = Profile