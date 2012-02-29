window.Paginated =
  hasFullPages: (perPage) ->
    return @length > 0 && @length % perPage == 0

HasMoreResults =
  hasMoreResults: ->
    return @_hasMoreResults

  setHasMoreResults: (results) ->
    @_hasMoreResults = results.length >=
      Constants.SPLASHBOARD_ITEMS_PER_PAGE

class window.AccessRequest extends Backbone.Model
  urlRoot: '/access_requests'

class window.Relationship extends Backbone.Model
  urlRoot: '/relationships'

class window.Track extends Backbone.Model
  flag: ->
    $.ajax
      type: 'post'
      url: '/tracks/' + @get('id') + '/flag'

class window.UndiscoveredTrack extends Track
  urlRoot: '/undiscovered_tracks'

class window.TrackList extends Backbone.Collection
  model: Track
  url: '/tracks'

class window.User extends Backbone.Model

class window.UserList extends Backbone.Collection
  model: User
  url: '/users'

class window.SuggestedSplasher extends Backbone.Model
  urlRoot: '/suggested_splashers'

class window.SuggestedSplashers extends Backbone.Collection
  model: SuggestedSplasher
  url: '/suggested_splashers'

class window.Comment extends Backbone.Model
  url: "/comments"

class window.CommentList extends Backbone.Collection
  model: Comment

  create: (c, opts) ->
    c.splash_id = @parent().get('id')

    super this, c, opts

  parent: (p) ->
    if p
      @_parent = p

      this
    else
      @_parent

class window.Event extends Backbone.Model

class window.Splash extends Event
  initialize: (attrs) ->
    @_comments = new CommentList(attrs.comments).parent(this)

    @bind('change', @resetComments, this)

  comments: ->
    return @_comments

  resetComments: ->
    self = this

    @_comments.reset(@get('comments'))

  urlRoot: '/splashes'

  url: ->
    if @isNew()
      return @urlRoot
    else
      return @urlRoot + "/" + @get('id')

  share: (site) ->
    $.ajax
      type: 'post'
      url: '/splashes/' + @get('id') + '/share'
      data: {site: site}
      success: (data) ->
        $('[data-id = "' + data.id + '"].social_link')
          .find('img')
          .attr('src', '/images/twitter-btn-gray.png')

class window.SplashList extends Backbone.Collection
  url: "/splashes"

class window.EventList extends Backbone.Collection
  model: Event
  url: '/events'

  initialize: ->
    @setHasMoreResults(true)

  parse: (response) ->
    @recordUpdate(response)

    @setHasMoreResults(response.results)

    _.map response.results, (e) ->
      switch e.type
        when "splash" then new Splash(e)
        else               new Event(e)

  recordUpdate: (resp) ->
    @lastUpdate = resp.last_update_at

  updateCount: (filters, resultFunc) ->
    self = this
    f    = _.extend({count: true, last_update_at: @lastUpdate}, filters)

    $.get(@url, f).
      done (response) ->
        self.recordUpdate(response)

        resultFunc.call(this, response.results)

_(EventList.prototype).extend(Paginated)
_(EventList.prototype).extend(HasMoreResults)

class window.Notification extends Backbone.Model

class window.NotificationList extends Backbone.Collection
  url: '/notifications'

  markRead: ->
    $.ajax(Routes.reset_read_notifications_path(), {type: 'PUT'})

  unreadCount: (opts) ->
    $.ajax(@url, {data: {count: 1}}).done(opts.success)

class window.FriendsList extends Backbone.Collection
  url: '/friends'

class window.SocialConnection extends Backbone.Model
