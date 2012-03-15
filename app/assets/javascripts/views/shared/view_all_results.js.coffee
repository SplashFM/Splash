class ViewAllResults
  @addTo: (target, hide = true) ->
    target::viewAllResults = ->
      @$el.trigger 'search:expand', terms: @term()

    target::events = _.extend {}, target::events,
      'click a.view-all': 'viewAllResults'

    if hide then _.extend target::events, 'search:expand': 'hide'


window.ViewAllResults = ViewAllResults
