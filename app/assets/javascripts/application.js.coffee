#= require hamlcoffee
#= require lib
#= require routes
#= require models
#= require views
#= require_tree ./routers
#= require_tree ./templates

window.Scaphandrier = {}

Scaphandrier.Fancybox =
  params:
    customizations:
      'type' : 'ajax'
      'width' : 460
      'height': 480
      'autoScale' : false
      'autoDimensions' : false
      'titleShow' : false
      'overlayShow' : true
      'overlayColor' : '#000'
      'overlayOpacity' : 0.5
      'transitionIn' : 'none'
      'transitionOut' : 'none'
      'padding' : 0
      'margin' : 0
      'scrolling' : 'no'

Scaphandrier.Fancybox.Large =
  params:
    customizations: _.extend({}, Scaphandrier.Fancybox.params.customizations,
      'width':  760
      'height': 600
      'scrolling' : 'auto')
