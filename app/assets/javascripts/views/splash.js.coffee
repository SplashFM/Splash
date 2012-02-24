class Splash extends Backbone.View
  events:
    'click':                                        'toggleExpanded'
    'submit [data-widget = "comment-box"]':         'addComment'
    'keypress [data-widget = "comment-text-area"]': 'checkKeyDown'
    'click [data-widget = "play"]':                 'play'
    'click [data-widget = "flag"]':                 'flag'
  tagName: 'li'

  initialize: ->
    @enableExpansion()

    @model.bind 'change', @render

    $(@el).hover(@onHover, @onHoverOut)

    @siblings = new SplashList()
    @siblings.bind 'reset', @renderThumbnails

    $('body').bind 'splash:resplash splash:quick', @splashed

  checkKeyDown: (e) ->
    if e.keyCode == 13
      e.preventDefault()
      @addComment(e)

      false

  addComment: (e) ->
    e.preventDefault()

    @model.comments().create({
      body: @mentions.commentWithMentions()
      success: @onCommentAdded
    }, {wait: true})

  disableExpansion: =>
    @expand = false

  enableExpansion: =>
    @expand = true

  onCommentAdded: =>
    @reset()

    cCount = I18n.t('comments', {count: @model.comments().length})

    @$('[data-widget = "comments-count"]').text(cCount)
    @$('[data-widget = "comment-text-area"]').css('height', 19)

  onHover: =>
    @$('[data-widget = "play"] span').css('display', 'block')

  onHoverOut: =>
    @$('[data-widget = "play"] span').hide()

  toggleExpanded: (e) ->
    if @options.disableToggling then return

    if @expand and
      (!e or
        (($(e.target).closest('[data-widget = "expand"]').length > 0 or
          $(e.target).closest('[data-widget = "comments-count"]').length > 0 or
          $(e.target).closest('a').length == 0) and
         $(e.target).closest('[data-widget = "more-info"]').length == 0))

      if e then e.preventDefault()

      if @$('[data-widget = "more-info"]').length == 0
        @model.fetch()
      else
        $(@el).toggleClass('expanded')
        @$('[data-widget = "more-info"]').toggle()

  play: (e) ->
    e.preventDefault()

    $(@el).trigger('request:play', track: @model.get('track'))

  splashed: (_, data) =>
    if data.track.id == @model.get('track').id
      @$('[data-widget = "splash"]').
        removeClass('splashable').
        addClass('unsplashable')

  flag: ->
    track = new Track(@model.get('track'))

    track.flag()

    @$('[data-widget = "flag"]').
      replaceWith($("<span/>").
                    text("Thanks!").
                    addClass('report-song').
                    addClass('right'))

  loadThumbnails: (onLoad) =>
    @$('[data-widget = "thumbnails"]').addClass('loading')

    @siblings.fetch
      data:
        splashed: @model.get('track').id
        tree_with: @options.currentUserID

  render: =>
    s          = @model
    commentStr = I18n.t('comments', {count: s.get('comments_count')})
    createdAt  = $.timeago(s.get('created_at'))
    ext        = {created_at: createdAt, comment_count: commentStr}
    json       = _.extend(s.toJSON(), ext)

    $(@el).html($.tmpl(@template, json))
    SPLASH.Widgets.numFlipper($('.the_splash_count',@el))

    @resplash = new FullSplashAction
      el:     @$('[data-widget = "full-splash-action"]')
      model:  new Track(@model.get('track'))
      parent: @model

    @resplash.bind 'splash:open', @disableExpansion
    @resplash.bind 'splash:close', @enableExpansion

    if @model.get('expanded')
      $(@el).addClass('expanded')

      @comments = new Comments
        el:         @$('[data-widget = "comments"]').get(0)
        collection: @model.comments()

      @comments.render()

      @mentions = new UserMentions
        el: @$('.comment-text-area')
        parent: @el

      @loadThumbnails()

    $(@el).find(".expand").each ->
      if $(this).hasClass('comment-text-area')
        $(this).TextAreaExpander(12)
      else
        $(this).TextAreaExpander(70)

    fixBG @$('.the_water, .noise-overlay, .numHolder, .numHolderCount')

    this

  reset: =>
    @$('textarea').val ''

  renderThumbnails: =>
    ul   = $('<ul/>')
    self = this
    header = '<div class="header_label avan-demi">Splash Lineage:</div>'

    @siblings.each (s) ->
      li = $('<li/>').html($.tmpl(self.thumbTemplate, s.get('user')))

      if s.get('user').id == self.options.currentUserID
        li.addClass('highlight')

      ul.append(li)

    @$('[data-widget = "thumbnails"]').html(ul).removeClass('loading')
    @$('[data-widget = "thumbnails"]').prepend(header)


class Comments extends Backbone.View
  initialize: ->
    @collection.bind 'add', @renderComment

  render: ->
    @collection.each @renderComment

  renderComment: (c) =>
    createdAt = $.timeago(c.get('created_at'))
    json      = _.extend(c.toJSON(), created_at: createdAt)

    $(@el).append $.tmpl(@template, json)


window.Feed.Splash = Splash

$ ->
  Splash.mixin Purchase

  Splash::template      = $('#tmpl-event-splash').template()
  Splash::thumbTemplate = $('#tmpl-user-thumbnail').template()

  Comments::template = $('#tmpl-event-splash-comment').template()
