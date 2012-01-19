$(function() {
  window.SplashboardController = Backbone.View.extend({
    initialize: function() {
      this.topTracks = new Splashboard.Items({
        template: '#tmpl-event-splash',
        feed: new TrackList,
        extraClass: 'live-feed',
        numFlipper: true,
      });
      this.topTracksScroll = new EndlessScroll({
        data: this.topTracks,
        spinnerContainer: $('#tab-top-tracks .loading-spinner-container'),
        noMoreResults: $('<p/>').
          text(I18n.t('splashboards.all_loaded')).
          addClass('loaded'),
      });

      this.myTopTracks = new Splashboard.Items({
        template: '#tmpl-event-splash',
        feed: new TrackList,
        app: window.App,
        filters: {user_id: this.options.userID},
        extraClass: 'live-feed',
        numFlipper: true,
      });
      this.myTopTracksScroll = new EndlessScroll({
        data: this.myTopTracks,
        spinnerContainer: $('#tab-my-top-tracks .loading-spinner-container'),
        noMoreResults: $('<p/>').
          text(I18n.t('splashboards.all_loaded')).
          addClass('loaded'),
      });

      this.topUsers = new Splashboard.Items({
        template: '#tmpl-user',
        feed: new UserList,
        app: window.App,
        extraClass: 'live-feed',
        waterNums: true,
      });
      this.topUsersScroll = new EndlessScroll({
        data: this.topUsers,
        spinnerContainer: $('#tab-top-users .loading-spinner-container'),
        noMoreResults: $('<p/>').
          text(I18n.t('splashboards.all_loaded')).
          addClass('loaded'),
      });
    },

    render: function() {
      $('#tab-top-tracks').prepend(this.topTracks.el);
      $('#tab-my-top-tracks').prepend(this.myTopTracks.el);
      $('#tab-top-users').prepend(this.topUsers.el);

      $('.splashboard .tabs').tabs('select', this.options.selectedTab)
    },
  });

  window.Splashboard = {}
  Splashboard.Items = Backbone.View.extend({
    tagName: "ul",
    className: "splashboard-items",

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'fetchDone', 'renderItem');

      this.template = $(this.template).template();
      this.feed.bind('reset', this.render, this);
      this.feed.bind('add', this.renderItem, this);

      this.fetch();

      this.page = 1;

      if (opts.extraClass) {
        $(this.el).addClass(opts.extraClass)
      }
    },

    allFilters: function() {
      return {top: true};
    },

    fetch: function(add) {
      this.feed.fetch({
        add:     add,
        data:    _.extend({page: this.page}, this.allFilters(), this.filters),
        success: this.fetchDone
      });
    },

    fetchDone: function() {
      if (this.feed.hasMoreResults()) {
        this.trigger('scroll:loaded');
      } else {
        this.trigger('scroll:done');
      }
    },

    scroll: function() {
      if ($(this.el).is(':visible')) {
        this.page++;

        this.fetch(true);
      }
    },

    render: function() {
      $(this.el).empty();
      this.feed.each(this.renderItem);

      return this;
    },

    renderItem: function(s) {
      $(this.el).append(new SplashboardItem({
        model: s,
        template: this.template,
        numFlipper: this.options.numFlipper,
        waterNums: this.options.waterNums,
      }).render().el);
    },

    scroll: function(e) {
      if ($(this.el).is(":visible") && this.feed.hasMoreResults()) {
        this.page++;

        this.fetch(true);

        return true;
      } else {
        return false;
      }
    },
  });

  window.SplashboardItem = {}
  SplashboardItem = Backbone.View.extend({
    tagName: "li",
    events: {
      'click [data-widget = "play"]': 'play',
    },

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'togglePlay');

      this.template = opts.template;
    },

    render: function() {
      var s = this.model;
      /* HACK: to make tracks, but not users, look like splashes */
      if (s.get('avatar_thumb_url')) {
        var json = s.toJSON();
      } else {
        var json = {track: s.toJSON(), user: false};
      }
      $($.tmpl(this.template, json)).appendTo(this.el);

      if (this.options.waterNums) {
        SPLASH.Widgets.waterNums($('.splash-score',this.el));
      }

      if (this.options.numFlipper)
        SPLASH.Widgets.numFlipper($('.the_splash_count',this.el));

      new FullSplashAction({
        model: this.model,
        el: this.$('[data-widget = "full-splash-action"]').get(0),
      });

      this.$('[data-widget = "play"]').hover(this.togglePlay, this.togglePlay);

      return this;
    },

    play: function(e) {
      e.preventDefault();

      $(this.el).trigger('request:play',
                         {track: this.model.toJSON()});
    },

    togglePlay: function() {
      $(this.el).toggleClass('playable');
    },
  });

  window.Splashboard.ViewMore = Backbone.View.extend({
    initialize: function() {
      _.bindAll(this, 'onTabSelect');

      this.tabs = $(this.options.tabs);
      this.tabs.bind('tabsselect', this.onTabSelect);
    },

    onTabSelect: function(_, ui) {
      $(this.el).attr('href', this.options.lists[ui.index].url + "/top");
    },
  });
});
