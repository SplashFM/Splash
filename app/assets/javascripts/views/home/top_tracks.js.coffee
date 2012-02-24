class PeriodToggle extends Backbone.View
  className: 'splashboard-period'

  initialize: ->
    @period = @options.period

  render: ->
    @$el.html JST['home/period_toggle']()

    @$('input').attr('checked', @period == 'alltime')

    this


class TopTracks extends Page.Content
  label: 'home.top_splashes'

  initialize: ->
    super

    @period = @options.period
    @sample = @options.sample

    @routes       = Home.Router.routes

  renderTop: ($top) ->
    periodToggle = new PeriodToggle(period: @period)

    $top.append periodToggle.render().el
    $top.append JST['shared/nav_list'](
      links: [{
        href:  @routes.topTracks(@period, 'following')
        label: 'top.following'
      }, {
        href:  @routes.topTracks(@period, 'everyone')
        label: 'top.everyone'}]
      active:  "top.#{@sample}"
    )

  renderMain: ($main) ->

window.Home.TopTracks = TopTracks
