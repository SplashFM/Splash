class TopSplashers extends Page.Content
  label: 'follow.top_splashers'

  initialize: ->
    super

    @sample = @options.sample

    @feed   = Feed.feed this,
      Feed.emptiable @sample,
        collection: new UserList
        className: 'splashboard-items live-feed'
        filters:
          top:       true
          following: if @sample == 'following' then 1 else ''
        newItem: (i) -> new TopUser(model: i)

    @routes = Follow.Router.routes

  renderTop: ($top) ->
    $top.append JST['shared/nav_list'](
      links: [{
        href:  @routes.topSplashers('following')
        label: 'top.following'
      }, {
        href:  @routes.topSplashers('everyone')
        label: 'top.everyone'}]
      active:  "top.#{@sample}"
    )


Follow.TopSplashers = TopSplashers

class TopUser extends Backbone.View
  tagName: 'li'

  render: ->
    $($.tmpl(@template, @model.toJSON())).appendTo(@el)

    r = @model.get('relationship')

    if r.follower_id != r.followed_id
      new RelationshipView({
        el:       @$('.right .follow-links')
        model:    new Relationship(r)
        template: @templateRelationship
      }).render()

    SPLASH.Widgets.waterNums($('.splash-score',@el))

    this

Follow.TopSplashers.User = TopUser

$ ->
  TopUser::template             = $('#tmpl-user').template()
  TopUser::templateRelationship = $('#tmpl-relationship-list').template()
