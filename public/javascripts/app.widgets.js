$(function() {
  window.BaseApp = Backbone.View.extend({
    initialize: function() {
      this.trackSearch = new BaseApp.TrackSearch;
    }
  });

  window.BaseApp.TrackSearch = Search.extend({
    collection: new TrackList,
    el: '[data-widget = "global-search"]',
    menuContainer: '[data-widget = "tracks"] ul',
    template: '#tmpl-global-search-track',

    cycle: function(item, even, odd) {
      if (this.currentCycle != odd) {
        this.currentCycle = odd;
      } else {
        this.currentCycle = even;
      }

      if (this.currentCycle) item.addClass(this.currentCycle);
    },

    renderItem: function(i) {
      this.cycle(Search.prototype.renderItem.call(this, i), 'even', 'odd');
    }
  });

  window.App = new BaseApp
});