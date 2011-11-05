$(function() {
  window.Home = Backbone.View.extend({
    initialize: function() {
      this.trackSearch = new Home.TrackSearch()
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

  window.HomeApp = new Home;
});