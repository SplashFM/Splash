class Router extends Backbone.Router
  initialize: (opts) ->
    @app = opts.app

    @builder = new Router.Builder(@app.user)

  routes:
    'top/tracks/:period/:sample': 'topTracks'
    'latest/:sample':             'latestSplashes'
    'latest/:sample/:hashtag':    'latestSplashes'
    'home':                       'latestSplashes'
    'hashtag/:name/:sample':      'hashtags'
    
  latestSplashes: (sample = @builder.defaultSample(), hashtag = '') ->
    @setPage new Home.LatestSplashes
      app:    @app
      sample: sample
      hashtag: hashtag if hashtag != ''
  
  topTracks: (period = '7d', sample = 'everyone') ->
    @setPage new Home.TopTracks
      app:    @app
      period: period
      sample: sample

  setPage: (content) ->
    if @app.current?.constructor == Home
      @app.setContent content
    else
      @app.setPage new Home(content: content, app: @app)

  hashtags: (name, sample = @builder.defaultSample()) ->
    @setPage new Home.LatestSplashes
      app:    @app
      sample: sample
      hashtag: name

class Router.Builder
  constructor: (user) ->
    @user = user

  defaultSample: ->
    if @user.isNew() then 'everyone' else 'following'

  topTracks: (period = '7d', sample = 'everyone') ->
    "top/tracks/#{period}/#{sample}"

  latestSplashes: (sample = @defaultSample()) ->
    "latest/#{sample}"

  home: -> @latestSplashes()

Home.Router = Router
