$(function() {
  window.Splashboard = Backbone.View.extend({
    el: '[data-widget = "top-tracks"]',
    template: $('#tmpl-home-track').template(),

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'scroll', 'renderTrack');

      this.app         = opts.app;
      this.pageFilters = {user: this.currentUserId,
                          follower: this.currentUserId,
                          update_on_splash: true}
      this.userFilters = {};

      this.feed = new TrackList;
      this.feed.bind('reset', this.render, this);
      this.feed.bind('add', this.renderTrack, this);

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
      this.feed.each(this.renderTrack);
      return this;
    },
    renderTrack: function(s) {
      var json       = _.extend({}, s.toJSON());
      $($.tmpl(this.template, json)).appendTo(this.el);
    },
  });
});
