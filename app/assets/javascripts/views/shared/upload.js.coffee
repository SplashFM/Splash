class window.Upload extends Backbone.View
  className: 'uploadForm'
  tagName: 'div'

  initialize: ->
    @$el.clickout @hide

  hide: (args) =>
    @$el.hide()

    @metadata.reset()

    @$el.trigger "hiding"

    this

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

  show: ->
    @$el.show()

    @$el.trigger 'showing'

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

$ ->
  Upload::template = $('#tmpl-upload').template()
  Upload.Metadata::template = $('#tmpl-upload-metadata').template()
