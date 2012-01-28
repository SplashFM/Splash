$(function() {
  window.FriendsView = Backbone.View.extend({
    initialize: function() {
      FB.init({appId: this.options.appID, xfbml: true, cookie: true});
    },

    render: function() {
      this.friendsList = new FriendsListView({
        collection: this.options.friends,
        el: this.$('ul.live-feed').get(0)
      }).render();

      return this;
    }
  });

  window.FriendsListView = Backbone.View.extend({
    render: function() {
      this.collection.each(this.renderFriend, this);

      return this;
    },

    renderFriend: function(f) {
      switch (f.get('origin')) {
      case 'facebook':
        $(this.el).append(new UnregisteredFriendView({model: f}).render().el);

        break;
      default:
        $(this.el).append(new RegisteredFriendView({model: f}).render().el);
      }
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
    },
  });
});
