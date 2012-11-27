class Router extends Backbone.Router
  @routes:
    profile: (nickname, section = 'splashes') ->
      "#{nickname}/#{section}"

  initialize: (opts) ->
    @app = opts.app

  routes:
    ':nickname':          'profile'
    ':nickname/:section': 'profile'
    ':nickname/:section/:hashtag': 'profile'
  
  profile: (nickname, section = 'splashes', hashtag = '') ->
    if @app.current?.constructor == Profile and @app.current.user.get('nickname') == nickname
      @app.setContent new Profile.Content 
        app:     @app
        user:    @app.current.user
        section: section
        hashtag: hashtag if hashtag != ''
    else
      @setProfile(
        nickname
        section
        hashtag: hashtag if hashtag != ''  
      )
  setProfile: (nickname, section, hashtag = '') ->
    if nickname != @app.user.get('nickname')
      user = new User(id: nickname)
      user.fetch().then =>
        @setPage new Profile.Content(app: @app, user: user, section: section, hashtag: hashtag), user
    else
      @setPage new Profile.Content(app: @app, user: @app.user, section: section, hashtag: hashtag), @app.user

  setPage: (content, user) ->
    @app.setPage new Profile(app: @app, content: content, user: user, profile: true)


Profile.Router = Router
