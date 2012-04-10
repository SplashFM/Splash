class Splash extends Backbone.View
  events:
    'submit [data-widget = "comment-box"]':         'addComment'
    'keypress [data-widget = "comment-text-area"]': 'checkKeyDown'
    'click [data-widget = "play"]':                 'play'
  tagName: 'li'

  initialize: ->
    @enableExpansion()

    @model.bind 'change', @render

    $(@el).hover(@onHover, @onHoverOut)

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
    }, {
      success: @onCommentAdded
      wait: true
    })

  disableExpansion: =>
    @expand = false

  enableExpansion: =>
    @expand = true

  expanded: ->
    @model.fetch()

  onCommentAdded: =>
    @reset()

    cCount = I18n.t('comments', {count: @model.comments().length})

    @$('[data-widget = "comments-count"]').text(cCount)
    @$('[data-widget = "comment-text-area"]').css('height', 19)

  onHover: =>
    @$('[data-widget = "play"] span').css('display', 'block')

  onHoverOut: =>
    @$('[data-widget = "play"] span').hide()

  play: (e) ->
    e.preventDefault()

    $(@el).trigger('play', track: @model.get('track'))

  splashed: (_, data) =>
    if data.track.id == @model.get('track').id
      @$('[data-widget = "splash"]').
        removeClass('splashable').
        addClass('unsplashable')

      @number.incr()

  render: =>
    s          = @model
    commentStr = I18n.t('comments', {count: s.get('comments_count')})
    createdAt  = $.timeago(s.get('created_at'))
    ext        = {created_at: createdAt, comment_count: commentStr}
    json       = _.extend(s.toJSON(), ext)

    $(@el).html($.tmpl(@template, json))
    @number = new FlipNumber({
      el: $('.the_splash_count',@el).get(0),
      value: json.track.splash_count
    }).render()

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

      new Splash.Lineage
        el:              @$('[data-widget = "thumbnails"]').get(0)
        model:           new Track(@model.get('track'))
        userHighlightID: @options.currentUserID

    $(@el).find(".expand").each ->
      if $(this).hasClass('comment-text-area')
        $(this).TextAreaExpander(12)
      else
        $(this).TextAreaExpander(70)

    fixBG @$('.the_water, .noise-overlay, .numHolder, .numHolderCount')

    this

  reset: =>
    @$('textarea').val ''


class Comments extends Backbone.View
  initialize: ->
    @collection.bind 'add', @renderComment

  render: ->
    @collection.each @renderComment

  renderComment: (c) =>
    createdAt = $.timeago(c.get('created_at'))
    json      = _.extend(c.toJSON(), created_at: createdAt)

    $(@el).append $.tmpl(@template, json)


class FlipNumber extends Backbone.View
  initialize: ->
    @value = @options.value

  incr: ->
    pad  = ['0', '0', '0']
    prev = pad.concat(@value.toString().split('')).slice(-3)
    next = pad.concat((@value + 1).toString().split('')).slice(-3)

    $next = $('<div/>').text(next.join(''))

    SPLASH.Widgets.numFlipper($next)

    _(prev).chain().zip(next).each ([p, n], i) =>
      if p != n
        $o = @$(".digit_#{i}")
        $p = $o.clone().css float: 'none', position: 'absolute', left: 0
        $n = $next.find(".digit_#{i}").css
          float: 'none'
          position: 'absolute'
          left: 0
        $c = $("<div/>").width($o.width()).height($o.height()).css
          overflow: 'hidden'
          position: 'absolute'
          float:    'left'
          left:     $o.css('left')

        $o.replaceWith $c.
          append($p).
          append($n.css(top: $p.position().top + $p.height()))

        speed = 500

        $n.animate {top: 0}, speed
        $p.animate {top: (- $p.height()) + 'px'}, speed


  render: ->
    SPLASH.Widgets.numFlipper(@$el)

    this

class Splash.Lineage extends Backbone.View
  initialize: ->
    @userHighlightID = @options.userHighlightID
    @siblings        = new SplashList()

    @siblings.bind 'reset', @loaded
    @siblings.bind 'reset', @render

    @load()

  load: ->
    @loading()

    @siblings.fetch data: {splashed: @model.id}

  loaded: =>
    @$el.removeClass 'loading'

  loading: ->
    @$el.addClass 'loading'

  render: =>
    ul   = $('<ul/>')
    header = '<div class="header_label avan-demi">Splash Lineage:</div>'

    @siblings.each (s) =>
      li = $('<li/>').html($.tmpl(@template, s.get('user')))

      if s.get('user').id == @userHighlightID
        li.addClass('highlight')

      ul.append(li)

    @$el.html(ul).removeClass 'loading'
    @$el.prepend header


class Splash.Expandable
  @mixInto: (target) ->
    target::events ?= {}

    _(target::events).extend(click: 'toggleExpanded')

    _(target.prototype).extend toggleExpanded: (e) ->
      if @options.disableToggling then return

      if e
        isCommentToggle =
          $(e.target).closest('[data-widget = "comments-count"]').length > 0
        isAction        = $(e.target).closest('a').length > 0
        isForm          = $(e.target).closest('form').length > 0
        isExpandedArea  =
          $(e.target).closest('[data-widget = "more-info"]').length > 0

      if @expand and
          (!e or isCommentToggle or (!isAction and !isForm and !isExpandedArea))
        if e then e.preventDefault()

        if @$('[data-widget = "more-info"]').length == 0
          @expanded()
        else
          $(@el).toggleClass('expanded')
          @$('[data-widget = "more-info"]').toggle()

Splash.Expandable.mixInto(Splash)

# this should be a real class
class Splash.Reportable
  @mixInto: (target, getTrack) ->
    target::events ?= {}

    _(target::events).extend 'click [data-widget = "flag"]': 'flag'

    _(target.prototype).extend flag: (e) ->
      e.preventDefault()

      getTrack(this).flag()

      @$('[data-widget = "flag"]').
        replaceWith($("<span/>").
                      text("Thanks!").
                      addClass('report-song').
                      addClass('right'))

Splash.Reportable.mixInto Splash, (splash) ->
  new UndiscoveredTrack(splash.model.get('track'))

window.Feed.Splash = Splash

$ ->
  Splash.mixin Purchase

  Splash::template         = $('#tmpl-event-splash').template()
  Splash.Lineage::template = $('#tmpl-user-thumbnail').template()

  Comments::template = $('#tmpl-event-splash-comment').template()
