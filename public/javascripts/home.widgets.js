$(function() {
  window.Home = Backbone.View.extend({
    initialize: function(opts) {
      this.trackSearch = new Home.TrackSearch(opts.search)
      this.feed        = new Events(opts.events);
      this.app         = opts.app;

      this.app.bind('endlessScroll', this.feed.scroll, this)
    },
  });

  Home.TrackSearch = Search.extend({
    collection: new TrackList,
    el: '[data-widget = "track-search"]',
    menuContainer: 'ul',

    open: function() {
      this.menu.find('li:last').addClass('last');
    },

    renderItem: function(i) {
      var opts = {model: i};

      $(new Home.TrackSearch.Track(opts).render().el).appendTo(this.menu);
    },
  });

  Home.TrackSearch.Track = Backbone.View.extend({
    tagName: 'li',
    template: $('#tmpl-home-track').template(),

    render: function() {
      $(this.el).attr('data-track_id', this.model.get('id'));
      $(this.el).html($.tmpl(this.template, this.model.toJSON()).html());

      new Home.TrackSearch.Track.FullSplashAction({
        model: this.model,
        el: $('[data-widget = "full-splash-action"]', this.el),
      });

      return this;
    },
  });

  Home.TrackSearch.Track.FullSplashAction = BaseApp.SplashAction.extend({
    events: {
      'click a': 'toggle',
      'submit form': 'splash'
    },

    splash: function() {
      new Splash().save({
        comment:  this.$('form textarea').val(),
        track_id: this.model.get('id')
      }, {
        success: this.broadcastSplash
      });
    },

    toggle: function() {
      this.$('form').toggle();
    },
  });
});