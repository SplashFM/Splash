$(function() {
  window.FriendsView = Backbone.View.extend({
    initialize: function() {
      FB.init({appId: this.options.appID, xfbml: true, cookie: true});
    },

    render: function() {
      var friends = new FriendsList;

      if (this.options.social) {
        this.friendsList = new FriendsListView({
          collection: friends,
          el: this.$('ul.live-feed').get(0),
          social: new SocialConnection(this.options.social)
        }).render();

        this.friendsScroll = new EndlessScroll({
          data: this.friendsList,
          spinnerContainer: $('.loading-spinner-container'),
          noMoreResults: $('<p/>').
            text(I18n.t('friends.all_loaded')).
            addClass('loaded'),
        });

        friends.fetch();
      }

      this.search = new FriendSearch({
        collection: friends
      });

      return this;
    }
  });

  window.FriendSearch = Search.extend({
    el: '[data-widget = "friend-search"]',

    initialize: function() {
      Search.prototype.initialize.call(this);

      this.bind('reset', this.cleared, this);
    },

    cleared: function() {
      this.collection.fetch();
    },

    render: function() {
      // no need
    },
  });

  window.FriendsListView = Backbone.View.extend({
    initialize: function() {
      this.collection.bind('add', this.renderFriend, this);
      this.collection.bind('reset', this.render, this);

      this.page = 1;
    },

    render: function() {
      $(this.el).empty();

      this.collection.each(this.renderFriend, this);

      return this;
    },

    renderFriend: function(f) {
      switch (f.get('origin')) {
      case 'facebook':
        $(this.el).append(new UnregisteredFriendView({
          model: f,
          social: this.options.social
        }).render().el);

        break;
      default:
        $(this.el).append(new RegisteredFriendView({model: f}).render().el);
      }
    },

    scroll: function(e) {
      if (this.keepScrolling == undefined) this.keepScrolling = true;
      if (! this.keepScrolling) return false;

      this.page++;

      var length = this.collection.length;

      this.collection.fetch({
        add: true,
        data: {page: this.page},
        success: _.bind(function(c) {
          if (c.length != length) {
            this.trigger('scroll:loaded');
          } else {
            this.keepScrolling = false;

            this.trigger('scroll:done');
          }
        }, this)
      });

      return true;
    },
  });

  window.FriendView = Backbone.View.extend({
    tagName: 'li',
    template: $('#tmpl-user').template(),

    json: function() {
      return this.model.toJSON();
    },

    render: function() {
      $(this.el).html($.tmpl(this.template, this.json()));

      this.renderAction();

      return this;
    },
  });

  window.RegisteredFriendView = FriendView.extend({
    templateRelationship: $('#tmpl-relationship-list').template(),

    render: function() {
      FriendView.prototype.render.call(this);

      this.renderLeft();

      return this;
    },

    renderAction: function() {
      return new RelationshipView({
        el: this.$('.right .follow-links'),
        model:    new Relationship(this.model.get('relationship')),
        template: this.templateRelationship,
      }).render();
    },

    renderLeft: function() {
      var score = this.model.get('score');
      var inner = $('<div/>').addClass('inner').text(score);
      var outer = $('<div/>').addClass('outer').text(score).append(inner);
      var span  = $('<span/>').addClass('number avan-bold invite left');

      this.$('.splash-score').replaceWith(span.html(outer));
    },
  });

  window.UnregisteredFriendView = FriendView.extend({
    json: function() {
      return _.extend(this.model.toJSON(), {unregistered: true});
    },

    renderAction: function() {
      return new UnregisteredFriendView.Invite({
        el: this.$('.right .follow-links'),
        model: this.model,
        social: this.options.social
      }).render();
    },
  });

  window.UnregisteredFriendView.Invite = Backbone.View.extend({
    events: {'click a': 'createRequest'},
    template: $('#tmpl-friends-invite').template(),

    createRequest: function(e) {
      e.preventDefault();

      new AccessRequest({user: this.json()}).save({}, {
        success: _.bind(this.inviteCreated, this)
      });
    },

    inviteCreated: function(data) {
      FB.ui({
        to: data.get('social').uid,
        method: 'send',
        display: 'iframe',
        name: I18n.t('friends.invite.title'),
        description: I18n.t('friends.invite.description'),
        link: data.get('social').url,
        access_token: this.options.social.get('token')
      }, function(response) {
      });
    },

    json: function() {
      return {
        uid: this.model.get('uid'),
        provider: this.model.get('origin')
      };
    },

    render: function() {
      $(this.el).html($.tmpl(this.template, {state: 'invite'}));

      return this;
    }
  });
});
