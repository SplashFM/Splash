class window.Upload extends Backbone.View
  events:
    'click .toggle-upload': 'toggle',
    'upload:complete': 'remove'

  initialize: ->
    @$input = @$('input.field')

    @$el.clickout @remove

  render: =>
    @rendered = true

    @uploader = new Upload.Uploader()
    @feedback = new Upload.Feedback(el: @el, $input: @$input)
    @progress = @options.progress or
      new Upload.Feedback.Progress(el: @el, $progress: @$input)
    @status   = new Upload.Feedback.Status(el: @el, $status: @$input)

    @$('.wrap').append @uploader.render().el

    w.render() for w in [@feedback, @progress, @status]

  remove: =>
    if @rendered
      w.remove() for w in [@uploader, @feedback, @progress, @status]

      @rendered = false

  toggle: ->
    if @rendered then @remove() else @render()


class window.Upload.Uploader extends Backbone.View
  className: 'uploadForm'
  tagName: 'div'

  onProgress: (_, data) =>
    @$el.trigger('upload:progress', {
      percent: parseInt(data.loaded / data.total * 100)
    })

  onError: =>
    @$el.trigger 'upload:error'

  onStart: =>
    @$el.trigger 'upload:start'

  onUpload: (_, data) =>
    switch data.jqXHR.status
      when 201
        @metadata.setModel new UndiscoveredTrack(data.result), 'edit'

        @$el.trigger('upload:done')
      when 200
        @metadata.setModel new UndiscoveredTrack(data.result), 'splash'

        @$el.trigger('upload:splash')

  render: ->
    @$el.append($.tmpl(@template))

    @$('form').fileupload({
      progress: @onProgress
      start: @onStart
      done: @onUpload
      fail: @onError
    })

    @metadata = new Upload.Metadata(model: @model)

    @$el.append @metadata.render().el

    this


class Upload.Metadata extends Backbone.View
  events: {submit: 'onSubmit'}
  tagName: 'form'

  onComplete: =>
    @$('[name = "title"]').val('')
    @$('[name = "performers"]').val('')
    @$('[name = "albums"]').val('')
    @$('textarea').val('')

    @$el.trigger('upload:complete')

    @$('[data-widget = "metadata"]').hide()
    @$('[data-widget = "complete-upload"]').hide()

  onError: =>
    @$el.trigger('upload:error')

  onSubmit: (e) =>
    e.preventDefault()

    if @mode == 'edit'
      attrs =
        albums: @$('[name = "albums"]').val()
        comment: @comment.comment()
        title: @$('[name = "title"]').val()
        performers: @$('[name = "performers"]').val()

      @$el.trigger 'upload:metadata'

      @model.save(attrs, {
        error: @onError
        success: @onComplete
      })
    else
      new Splash().save({
        comment:  @comment.comment()
        track_id: @model.get('id')
      }, {
        success: @onComplete
      })

  render: ->
    @$el.html $.tmpl(@template)

    @comment = new SplashComment(el: @$('textarea'))

    @$('[data-widget = "complete-upload"]').hide()

    this

  reset: ->
    @$el.empty()

    @render()

  setModel: (model, mode) ->
    button = @$('[data-widget = "complete-upload"] input')

    @model = model
    @mode  = mode

    if (mode == 'edit')
      @$('[name = "title"]').val(model.get('title'))
      @$('[name = "performers"]').val(model.get('performers'))
      @$('[name = "albums"]').val(model.get('albums'))

      button.val(I18n.t('upload.save'))

      @$('[data-widget = "metadata"]').show()
    else
      button.val I18n.t('upload.splash')

    @$('[data-widget = "complete-upload"]').show()


class Upload.Feedback extends Backbone.View
  events:
    'upload:error': 'onError'
    'upload:start': 'onStart'

  initialize: ->
    @$input = @options.$input

  onError: ->
    @$input.addClass 'error'

  onStart: ->
    @$input.removeClass 'error'

  remove: ->
    @$el.removeClass('error').removeClass 'uploading'

    @$input.removeAttr 'disabled'

  render: ->
    @$el.removeClass('error').addClass 'uploading'

    @$input.attr 'disabled', true


class Upload.Feedback.Status extends Backbone.View
  events:
    'upload:done':     'onDone',
    'upload:error':    'onError',
    'upload:metadata': 'onMetadataSave',
    'upload:splash':   'onSplash',
    'upload:start':    'onStart',

  initialize: ->
    @$status = @options.$status

  onError: ->
    @$status.val I18n.t('upload.error')

  onMetadataSave: ->
    @$status.val I18n.t('upload.metadata')

  onDone: (e) ->
    @$status.val I18n.t('upload.done')

  onSplash: ->
    @$status.val I18n.t('upload.exists')

  onStart: ->
    @$status.val I18n.t('upload.start')

  remove: ->
    @$status.attr 'value', ''

  render: ->
    @$status.attr 'value', I18n.t('upload.waiting')


class Upload.Feedback.Progress extends Backbone.View
  events:
    'upload:start':    'onStart',
    'upload:progress': 'onProgress',

  progressBeginPos: -622,

  initialize: ->
    @$progress = @options.$progress

  onProgress: (_, data) ->
    @setUploadProgress data.percent

  onStart: ->
    @setUploadProgress 0

  remove: ->

  render: ->
    @onStart()

  setUploadProgress: (percent) ->
    increment = Math.ceil(@$progress.width() * percent / 100)
    adjust    = Math.pow(increment / 100, 2)
    pos       = @progressBeginPos + increment + adjust

    @$progress.css('background-position', pos + 'px 0');


$ ->
  Upload.Uploader::template = $('#tmpl-upload').template()
  Upload.Metadata::template = $('#tmpl-upload-metadata').template()
