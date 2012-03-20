class TemplateView extends Backbone.View
  initialize: ->
    @template = @options.template
    @args     = @options.args

  render: ->
    @$el.html @template(@args)

    this

window.TemplateView = TemplateView
