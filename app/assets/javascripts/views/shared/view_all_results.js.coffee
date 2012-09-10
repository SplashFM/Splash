class ViewAllResults
  @addTo: (target, hide = true) ->
    target::viewAllResults = ->
      @$el.trigger 'search:expand', terms: @term()

    target::viewAllUserResults = ->
      @$el.trigger 'userSearch:expand', terms: @term()

    target::events = _.extend {}, target::events,
      'click a.view-all': 'viewAllResults',
      'click a.view-all-users': 'viewAllUserResults'
      

    if hide then _.extend target::events, 'search:expand': 'hide'
    if hide then _.extend target::events, 'userSearch:expand': 'hide'


window.ViewAllResults = ViewAllResults
