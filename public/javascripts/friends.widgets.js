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

    render: function() {
      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      return this;
    }
  });
});
