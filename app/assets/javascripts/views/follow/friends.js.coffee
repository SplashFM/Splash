class Friends extends Page.Content
  label: 'follow.friends'
  className: 'friends'

  initialize: ->
    super

    @collection = new FriendsList
    @feed       = Feed.feed this,
      collection: @collection
      className:  'live-feed'
      newItem:    (i) ->
        fb = window.app.user.get('facebook_token')

        switch i.get('origin')
          when 'facebook' then new UnregisteredFriendView(model: i, social: fb)
          else                 new RegisteredFriendView(model: i)

    @routes = Follow.Router.routes

  renderTop: ($top) ->
    $top.append new FriendSearch(collection: @collection).el


window.Follow.Friends = Friends


class FriendSearch extends Search
  className: 'main-search'

  initialize: ->
    super()

    @bind('reset', @cleared, this)

    @$el.html JST['follow/friend_search']()

  cleared: -> @collection.fetch()

  render: ->


class FriendView extends Backbone.View
  tagName: 'li'

  json: -> @model.toJSON()

  render: ->
    @$el.html $.tmpl(@template, @json())

    @renderAction()

    this


class RegisteredFriendView extends FriendView
  render: ->
    super()

    @renderLeft()

    this

  renderAction: ->
    return new RelationshipView(
      el: @$('.right .follow-links')
      model:    new Relationship(@model.get('relationship'))
      template: @templateRelationship
    ).render()

  renderLeft: ->
    score = @model.get('score')
    inner = $('<div/>').addClass('inner').text(score)
    outer = $('<div/>').addClass('outer').text(score).append(inner)
    span  = $('<span/>').addClass('number avan-bold invite left')

    @$('.splash-score').replaceWith(span.html(outer))


class UnregisteredFriendView extends FriendView
  json: -> _.extend(@model.toJSON(), unregistered: true)

  renderAction: ->
    return new UnregisteredFriendView.Invite(
      el: @$('.right .follow-links')
      model: @model
      social: @options.social
    ).render()


class UnregisteredFriendView.Invite extends Backbone.View
  events: {'click a': 'createRequest'}

  createRequest: (e) ->
    e.preventDefault()

    if @isInvited then return

    new AccessRequest(user: @json()).save({}, success: @inviteCreated)

  inviteCreated: (data) =>
    FB.ui({
      to: data.get('social').uid
      method: 'send'
      display: 'iframe'
      name: I18n.t('friends.invite.title')
      description: I18n.t('friends.invite.description')
      link: data.get('social').url
      access_token: @options.social
    }, @invited)

  invited: (response) =>
    if response
      @isInvited = true

      @$('a').
        removeClass('follow').
        addClass('invited').
        text(I18n.t('friends.invite.invited'))

  json: ->
    uid: @model.get('uid')
    provider: @model.get('origin')

  render: ->
    $(@el).html($.tmpl(@template, state: 'invite'))

    this

$ ->
  FriendView::template = $('#tmpl-user').template()
  RegisteredFriendView::templateRelationship =
    $('#tmpl-relationship-list').template()
  UnregisteredFriendView.Invite::template = $('#tmpl-friends-invite').template()
