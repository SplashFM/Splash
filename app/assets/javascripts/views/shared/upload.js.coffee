class Upload extends Backbone.View
  events:
    'click .toggle-upload': 'toggle',
    'upload:start':         'uploading',
    'upload:error'   :         'uploaded',
    'upload:alreadySplashed' : 'uploaded',
    'upload:unauthorized'    : 'uploaded',
    'upload:complete'        : 'uploaded'

  initialize: ->
    @$input    = @$('input.field')
    @$inputDup = @$input.clone()

    @$el.clickout => if not @isUploading then @remove()

  render: =>
    @rendered = true

    @$input.parent().append(@$inputDup).position(@$input.position())
    @$input.hide()

    @uploader = new Upload.Uploader()
    @feedback = new Upload.Feedback(el: @el, $input: @$inputDup)
    @progress = @options.progress or
      new Upload.Feedback.Progress(el: @el, $progress: @$inputDup)
    @status   = new Upload.Feedback.Status(el: @el, $status: @$inputDup)

    @$('.wrap').append @uploader.render().el

    w.render() for w in [@feedback, @progress, @status]

  remove: =>
    if @rendered
      w.remove() for w in [@uploader, @feedback, @progress, @status, @$inputDup]

      @$input.show()

      @rendered = false

  toggle: ->
    if @rendered
      @uploaded()
      @remove()
    else
      @render()

  uploading: =>
    @isUploading = true

  uploaded: =>
    @isUploading = false
    true


class Upload.Uploader extends Backbone.View
  className: 'uploadForm'
  tagName: 'div'

  onProgress: (_, data) =>
    console.log("In progress ... -----------------")
    console.log(data.loaded + "  " + data.total)
    @$el.trigger('upload:progress', {
      percent: parseInt(data.loaded / data.total * 100)
    })

  onError: (_, data) =>
    console.log("Failed -----------------")
    console.log(data.jqXHR.status)
    console.log(data.errorThrown)
    console.log(data.textStatus)
    @$el.trigger 'upload:error'

  onStart: =>
    console.log("In Start ... -----------------");
    @$el.trigger 'upload:start'

  onUpload: (_, data) =>
    console.log("Success -----------------")
    console.log(data.jqXHR.status)
    console.log(data.errorThrown)
    console.log(data.textStatus)
    switch data.jqXHR.status
      when 201
        @metadata.setModel new UndiscoveredTrack(data.result), 'edit'
        @hide()
        @$el.trigger('upload:done')
      when 200
        @metadata.setModel new UndiscoveredTrack(data.result), 'splash'
        @$el.trigger('upload:splash')
      when 226 # :status => :im_used  
        #@$el.trigger('upload:error')
        @$el.trigger('upload:alreadySplashed')  
      when 203
        @hide()
        @metadata.setError() 
        #@$el.trigger('upload:error')
        @$el.trigger('upload:unauthorized')  
  
  hide: ->
    @$('form#choose_file').hide()
  
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

  onComplete: (splash) =>
    @$el.trigger 'upload:complete', splash: splash

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
    @$('[data-widget = "upload-error"]').hide()

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
      button.val I18n.t('upload.resplash')

    @$('[data-widget = "complete-upload"]').show()
  
  setError: ->
    @$('[data-widget = "upload-error"]').show()
    @$("textarea.splash-comment-area").hide()


class Upload.Feedback extends Backbone.View
  events:
    'upload:error': 'onError'
    'upload:alreadySplashed' : 'onError'
    'upload:unauthorized'    : 'onError'
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
    'upload:alreadySplashed': 'onAlreadySplashed',
    'upload:unauthorized': 'onCopyright'

  initialize: ->
    @$status = @options.$status
  onCopyright: ->
    @$status.val I18n.t('upload.copyright_material')
  
  onAlreadySplashed: ->
    @$status.val I18n.t('upload.already_splashed')

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
    pos       = @progressBeginPos + increment

    @$progress.css('background-position', pos + 'px 0');

window.Upload = Upload

$ ->
  Upload.Uploader::template = $('#tmpl-upload').template()
  Upload.Metadata::template = $('#tmpl-upload-metadata').template()
