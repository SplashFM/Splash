$(function() {
  window.HomeTrackSearch = Backbone.View.extend({
    delay: 500,

    el: '[data-widget = "track-search"]',

    events: {
      'keyup :text': 'maybeSearch'
    },

    template: $('#tmpl-home-track').template(),

    initialize: function() {
      this.tracks  = new TrackList
      this.results = this.$('[data-widget = "results"]');
      this.menu    = $('ul', this.results);

      _.bindAll(this, 'search', 'renderTrack');

      this.tracks.bind('reset', this.render, this)
    },

    isSearchable: function() {
      return this.term().length > 0 && this.lastTerm !== this.term();
    },

    maybeSearch: function() {
      if (this.timeout) clearTimeout(this.timeout);

      this.timeout  = setTimeout(this.search, this.delay);
    },

    render: function() {
      this.menu.empty();
      this.tracks.each(this.renderTrack);
      this.menu.find('li:last').addClass('last');

      this.results.show();
    },

    renderTrack: function(t) {
      this.menu.append($.tmpl(this.template, t.toJSON()));
    },

    search: function() {
      if (this.isSearchable()) {
        this.lastTerm = this.term();

        this.tracks.fetch({data: {with_text: this.term()}});
      }
    },

    term: function() {
      return this.$(':text').val();
    }
  });

  window.Home = Backbone.View.extend({
    initialize: function() {
      this.trackSearch = new HomeTrackSearch
    }
  });

  window.HomeApp = new Home;
});