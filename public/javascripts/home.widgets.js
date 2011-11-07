$(function() {
  window.Home = Backbone.View.extend({
    initialize: function(opts) {
      this.trackSearch = new Home.TrackSearch(opts.search)
      this.feed        = new Events(opts.events);
    }
  });

  Home.TrackSearch = Search.extend({
    collection: new TrackList,
    el: '[data-widget = "track-search"]',
    menuContainer: 'ul',
    template: '#tmpl-home-track',

    open: function() {
      this.menu.find('li:last').addClass('last');
    }
  });
});