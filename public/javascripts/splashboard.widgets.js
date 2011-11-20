$(function() {

  window.Splashboard = {}
  Splashboard.Items = Backbone.View.extend({
    tagName: "ul",
    className: "splashboard-items",

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'scroll', 'renderItem');

      this.app         = opts.app;

      this.template = $(this.template).template()
      this.feed.bind('reset', this.render, this);
      this.feed.bind('add', this.renderItem, this);

      this.fetch();

      this.page = 1;
      if (this.app) {
        this.app.bind('endlessScroll', this.scroll, this)
      }
      if (opts.extraClass) {
        $(this.el).addClass(opts.extraClass)
      }
    },

    allFilters: function() {
      return {top: true};
    },

    fetch: function(add) {
      this.feed.fetch({add:  add,
                       data: _.extend({page: this.page},
                                      this.allFilters(), this.filters)});
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
      $(this.el).append(new SplashboardItem({
        model: s,
        template: this.template,
        numFlipper: this.options.numFlipper,
        waterNums: this.options.waterNums,
      }).render().el);
    },
  });

  window.SplashboardItem = {}
  SplashboardItem = Backbone.View.extend({
    tagName: "li",
    events: {
      'click [data-widget = "play"]': 'play'
    },

    initialize: function(opts) {
      _.extend(this, opts);

      //_.bindAll(this, 'scroll', 'renderItem', 'play');
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

      new TrackSearch.Track.FullSplashAction({
        model: this.model,
        el: this.$('[data-widget = "full-splash-action"]').get(0),
      });
      return this;
    },

    play: function(e) {
      e.preventDefault();

      $(this.el).trigger('request:play',
                         {track: this.model.toJSON()});
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
