class TemplateView extends Backbone.View
  initialize: ->
    @template = @options.template

  render: ->
    @$el.html @template()

    this

window.TemplateView = TemplateView
