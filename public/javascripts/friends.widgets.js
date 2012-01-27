$(function() {
  window.FriendsView = Backbone.View.extend({
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
      $(this.el).append(new FriendView({model: f}).render().el);
    },
  });

  window.FriendView = Backbone.View.extend({
    template: $('#tmpl-user').template(),
    templateRelationship: $('#tmpl-relationship-list').template(),

    render: function() {
      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      this.renderAction();

      return this;
    },

    renderAction: function() {
      return new RelationshipView({
        el: this.$('.right .follow-links'),
        model:    new Relationship(this.model.get('relationship')),
        template: this.templateRelationship,
      }).render();
    },
  });
});
