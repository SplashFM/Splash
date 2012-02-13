$(function() {
  splash.board = {};

  splash.board.Items = Backbone.View.extend({
    initialize: function(options) {
      this.paginatedCollection = this.options.paginatedCollection;

      this.list = new BoundList({
        className: 'splashboard-items live-feed',
        collection: this.paginatedCollection.collection(),
        itemConstructor: function(item) {
          return new options.itemType({model: item});
        }
      });
    },

    activate: function() {
      this.scroll.activate();
    },

    deactivate: function() {
      this.scroll.deactivate();
    },

    render: function() {
      $(this.el).append(this.list.el);
      $(this.el).append($('<div class="loading-spinner-container"></div>'));

      this.scroll = new splash.EndlessScroll({
        data: this.paginatedCollection,
        document: document,
        spinnerContainer: this.$('.loading-spinner-container'),
        noMoreResults: $('<p/>').
          text(I18n.t('splashboards.all_loaded')).
          addClass('loaded'),
      }).scroll();

      return this;
    },
  });

  splash.board.Track = Backbone.View.extend({
    tagName: "li",
    template: $('#tmpl-event-splash').template(),
    events: {
      'click [data-widget = "play"]': 'play',
    },

    initialize: function() {
      _.bindAll(this, 'togglePlay');
    },

    render: function() {
      var json = {track: this.model.toJSON(), user: false};

      $($.tmpl(this.template, json)).appendTo(this.el);

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

      $(this.el).trigger('request:play', {track: this.model.toJSON()});
    },

    togglePlay: function() {
      $(this.el).toggleClass('playable');
    },
  });

  splash.board.User = Backbone.View.extend({
    tagName: 'li',
    template: $('#tmpl-user').template(),
    templateRelationship: $('#tmpl-relationship-list').template(),

    render: function() {
      $($.tmpl(this.template, this.model.toJSON())).appendTo(this.el);

      var r = this.model.get('relationship');

      if (r.follower_id != r.followed_id) {
        this.relationship = new RelationshipView({
          el: this.$('.right .follow-links'),
          model:    new Relationship(r),
          template: this.templateRelationship,
        }).render();
      }

      SPLASH.Widgets.waterNums($('.splash-score',this.el));

      return this;
    },
  });

  splash.board.Manager = Backbone.View.extend({
    handles: {
      following: I18n.t('splashboards.following'),
      week:      I18n.t('splashboards.week')
    },
    itemTypes: {
      tracks: splash.board.Track,
      users:  splash.board.User,
    },
    listTypes: {tracks: TrackList, users: UserList},

    initialize: function() {
      this.splashboards = {};

      this.setupPeriodToggle();
    },

    activate: function(opts) {
      var label = $.param(opts);

      this.setupNavigationCues(opts);
      this.setupNavigation(opts)

      if (! this.splashboards[label]) {
        this.splashboards[label] = this.makeSplashboard(opts).render();
      }

      if (this.splashboard) {
        this.splashboard.deactivate();

        $(this.splashboard.el).detach();
      }

      this.splashboard = this.splashboards[label];
      $('#splashboard-container').append(this.splashboard.el);
      this.splashboard.activate();
    },

    collectionOpts: function(options) {
      return {
        top:       true,
        following: options.sample == 'following' ? 1 : '',
        week:      options.period == '7d' ? 1 : ''
      };
    },

    makeSplashboard: function(opts) {
      var listType = this.listTypes[opts.type];
      var pColl    = Paginate(new listType, 10, this.collectionOpts(opts));

      return new splash.board.Items({
        itemType: this.itemTypes[opts.type],
        paginatedCollection: pColl,
      });
    },

    setupNavigation: function(opts) {
      var eRoute = '/top/' + opts.type + '/everyone' +
        (opts.period ? '/' + opts.period : '');
      var fRoute = '/top/' + opts.type + '/following' +
        (opts.period ? '/' + opts.period : '');

      $('li.everyone a').attr('href', eRoute);
      $('li.following a').attr('href', fRoute);

      this.periodToggled = _.bind(function(e) {
        var period = opts.period == '7d' ? 'alltime' : '7d'

        app.routes.navigate('top/tracks/' + opts.sample + '/' + period,
                            {trigger: true});
      }, this);
    },

    setupNavigationCues: function(opts) {
      $('.inner-nav-tabs li').removeClass('selected');
      $('.feed-settings-tabs li').removeClass('ui-tabs-selected');

      if (opts.type == 'users') {
        $('li.top-splashers').addClass('selected')

        $('.splashboard-period').hide();
      } else {
        $('li.top-splashes').addClass('selected');

        $('.splashboard-period').show();
        $('input#alltime').attr('checked', opts.period == 'alltime');
      }

      $('li.' + opts.sample).addClass('ui-tabs-selected');
    },

    setupPeriodToggle: function() {
      $('#alltime').change(_.bind(function(e) {
        this.periodToggled(e);
      }, this));
    },
  })
});
