$(function() {
  window.Splashboard = Backbone.View.extend({
    initialize: function(opts) {
      this.topTracks = new Splashboard.Items(
        _.extend(opts, {
          el: '[data-widget = "top-tracks"]',
          template: $('#tmpl-home-track').template(),
          feed: new TrackList,
        }));
      this.topUsers = new Splashboard.Items(
        _.extend(opts, {
          el: '[data-widget = "top-users"]',
          template: $('#tmpl-user').template(),
          feed: new UserList,
        }));
    }
  });

  Splashboard.Items = Backbone.View.extend({
    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'scroll', 'renderItem');

      this.app         = opts.app;
      this.pageFilters = {user: this.currentUserId,
                          follower: this.currentUserId,
                          update_on_splash: true}
      this.userFilters = {};

      //this.feed = new TrackList;
      this.feed.bind('reset', this.render, this);
      this.feed.bind('add', this.renderItem, this);

      this.fetch();

      this.page = 1;
      this.app.bind('endlessScroll', this.scroll, this)

    },
    allFilters: function() {
      return {top: true};
    },

    fetch: function(add) {
      this.feed.fetch({add:  add,
                       data: _.extend({page: this.page},
                                      this.allFilters())});
    },
    scroll: function() {
      this.page++;

      this.fetch(true);
    },
    render: function() {
      $(this.el).empty();
      this.feed.each(this.renderItem);
      return this;
    },
    renderItem: function(s) {
      var json = s.toJSON();
      $($.tmpl(this.template, json)).appendTo(this.el);
    },
  });
});
