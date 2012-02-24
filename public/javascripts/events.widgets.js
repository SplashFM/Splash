$(function() {
  // TODO: Remove this disgusting copy-paste once this is moved
  // to BB routers
  window.SingleSplashController = Backbone.View.extend({
    events: {
      'search:expand': 'searchExpanded',
      'search:collapse': 'searchCollapsed',
      'search:loaded': 'checkSize'
    },

    initialize: function() {
      this.trackSearch = new TrackSearch({perPage: this.options.tracksPerPage});

      this.splash = new Events.Splash({
        model: this.options.splash,
        disableToggling: true,
        currentUserID: this.options.userID,
      });

      this.suggestedSplashers = new SuggestedSplashersView({
        el: this.$('[data-widget = "suggested-users"]').get(0),
        followerID: this.options.userID,
        splashersCount: this.options.suggestedUsersPerPage,
      });

      this.allResults = new TrackSearch.AllResults();
    },

    checkSize: function() {
      var off = $(this.allResults.el).offset();
      var arh = off.top + $(this.allResults.el).height();

      if ($(this.el).height() < arh) {
        $(this.el).height($(this.el).height() + arh - $(this.el).height());
      }
    },

    searchCollapsed: function() {
      this.trackSearch.enable();
    },

    searchExpanded: function(_, data) {
      this.trackSearch.disable();

      this.showAllResults(data.terms);
    },

    showAllResults: function(searchTerms) {
      this.$('.events-wrap').prepend(this.allResults.el);

      this.allResults.load(searchTerms);
    },

    render: function() {
      this.suggestedSplashers.render();
      this.allResults.render();

      $('[data-widget = "events"]').append(this.splash.render().el);

      return this;
    }
  });

  window.Events = Backbone.View.extend({
    el: '[data-widget = "events"]',
    updateInterval: 60000, // 1 minute

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'checkForUpdates', 'fetchDone', 'onSplash', 'refresh',
                      'renderEvent', 'renderUpdateCount');

      $('body').bind('upload:complete splash:splash', this.onSplash)

      this.feed = new EventList;
      this.feed.bind('reset', this.render, this);
      this.feed.bind('add', this.renderEvent, this);

      this.filterView = new Events.Filter;
      this.filterView.bind('change', this.refresh, this);

      this.settings = new Events.Settings({filters: this.options.filters});
      this.settings.bind('change', this.refresh, this);

      this.currentInterval = setInterval(this.checkForUpdates,
                                         this.updateInterval);

      // TODO: move to the events object when this attaches to #stream-feed
      $('[data-widget = "update-count"]').bind('click', this.refresh);

      this.refresh();
    },

    allFilters: function() {
      return _.extend({}, this.options.filters,
                          this.filterView.filters(),
                          this.settings.filters())
    },

    checkForUpdates: function() {
      this.feed.updateCount(this.updateCounterFilters(), this.renderUpdateCount);
    },

    disable: function() {
      this.settings.disable();

      $(this.el).block({
        baseZ: 50,
        message: null,
        overlayCSS: {opacity: 0}
      });
    },

    enable: function() {
      this.settings.enable();

      $(this.el).unblock();
    },

    fetch: function(add) {
      this.feed.fetch({
        add:     add,
        data:    _.extend({page: this.page}, this.allFilters()),
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

    onSplash: function() {
      this.refresh();
    },

    refresh: function() {
      this.page = 1;

      this.fetch();
      this.renderUpdateCount(0);
    },

    render: function() {
      $(this.el).empty();

      this.feed.each(this.renderEvent);
    },

    renderEvent: function(e) {
      switch (e.get('type')) {
      case 'splash':
        $(this.el).append(new Events.Splash({
          model: e,
          currentUserID: this.options.currentUserID,
        }).render().el);
        break;
      case 'relationship':
      case 'comment':
        $(this.el).append(new Events.Social({model: e}).render().el);
        break;
      default:
      }
    },

    renderUpdateCount: function(count) {
      var upd = $('[data-widget = "update-count"]');

      upd.text(I18n.t('events.updates', {count: count}))

      if (count === 0) {
        upd.addClass('no-new');
      } else {
        upd.removeClass('no-new');
      }
    },

    scroll: function(e) {
      if (this.feed.hasMoreResults()) {
        this.page++;

        this.fetch(true);

        return true;
      } else {
        return false;
      }
    },

    updateCounterFilters: function() {
      return this.options.updateFilters;
    },
  });

  var HEIGHT_WHEN_OPEN = 62;

  window.BaseApp.ReSplashAction = BaseApp.SplashAction.extend({
    events: {'click' : 'splash'},

    initialize: function() {
      BaseApp.SplashAction.prototype.initialize.call(this)
    },

    splash: function() {
      new Splash().save({track_id: this.model.get('track').id,
                         parent_id: this.model.get('id')},
                        {success: this.broadcastSplash});
    },
  });

  window.Events.Splash = Backbone.View.extend({
    events: {
      'click': 'toggleExpanded',
      'submit [data-widget = "comment-box"]': 'addComment',
      'keypress [data-widget = "comment-text-area"]': 'checkKeyDown',
      'click [data-widget = "play"]': 'play',
      'click [data-widget = "flag"]': 'flag'
    },
    tagName: 'li',
    template: $('#tmpl-event-splash').template(),
    thumbTemplate: $('#tmpl-user-thumbnail').template(),

    initialize: function() {
      _.bindAll(this, 'onCommentAdded', 'loadThumbnails', 'onHover',
                      'onHoverOut', 'reset', 'splashed');

      this.enableExpansion();

      this.model.bind('change', this.render, this);

      $(this.el).hover(this.onHover, this.onHoverOut);

      this.siblings = new SplashList();
      this.siblings.bind('reset', this.renderThumbnails, this);

      $('body').bind('splash:resplash splash:quick', this.splashed);
    },

    checkKeyDown: function(e) {
      if(e.keyCode==13) {
        e.preventDefault();
        this.addComment(e);
        return false;
      }
    },

    addComment: function(e) {
      e.preventDefault();

      this.model.comments().create({
        body: this.mentions.commentWithMentions()
      }, {
        success: this.onCommentAdded
      });
    },

    disableExpansion: function() {
      this.expand = false;
    },

    enableExpansion: function() {
      this.expand = true;
    },

    onCommentAdded: function() {
      this.reset();

      var cCount = I18n.t('comments', {count: this.model.comments().length});

      this.$('[data-widget = "comments-count"]').text(cCount);
      this.$('[data-widget = "comment-text-area"]').css('height', 19);
    },

    onHover: function() {
      this.$('[data-widget = "play"] span').css('display', 'block');
    },

    onHoverOut: function() {
      this.$('[data-widget = "play"] span').hide();
    },

    toggleExpanded: function(e) {
      if (this.options.disableToggling) return;

      if (this.expand &&
        (!e ||
          (($(e.target).closest('[data-widget = "expand"]').length > 0 ||
            $(e.target).closest('[data-widget = "comments-count"]').length > 0 ||
            $(e.target).closest('a').length == 0) &&
           $(e.target).closest('[data-widget = "more-info"]').length === 0))) {
        if (e) e.preventDefault();

        if (this.$('[data-widget = "more-info"]').length === 0) {
          this.model.fetch();
        } else {
          $(this.el).toggleClass('expanded');
          this.$('[data-widget = "more-info"]').toggle();
        }
      }
    },

    play: function(e) {
      e.preventDefault();

      $(this.el).trigger('request:play',
                         {track: this.model.get('track')});
    },

    splashed: function(_, data) {
      if (data.track.id === this.model.get('track').id) {
        this.$('[data-widget = "splash"]').
          removeClass('splashable').
          addClass('unsplashable');
      }
    },

    flag: function() {
      var track = new Track(this.model.get('track'));

      track.flag();

      this.$('[data-widget = "flag"]').
        replaceWith($("<span/>").
                      text("Thanks!").
                      addClass('report-song').
                      addClass('right'));
    },

    loadThumbnails: function(onLoad) {
      this.$('[data-widget = "thumbnails"]').addClass('loading');

      this.siblings.fetch({
        data: {
          splashed: this.model.get('track').id,
          tree_with: this.options.currentUserID,
        },
      })
    },

    render: function() {
      var s          = this.model;
      var commentStr = I18n.t('comments', {count: s.get('comments_count')});
      var createdAt  = $.timeago(s.get('created_at'));
      var ext        = {created_at: createdAt, comment_count: commentStr};
      var json       = _.extend(s.toJSON(), ext);

      $(this.el).html($.tmpl(this.template, json));
      SPLASH.Widgets.numFlipper($('.the_splash_count',this.el));

      this.resplash = new FullSplashAction({
        el:     this.$('[data-widget = "full-splash-action"]'),
        model:  new Track(this.model.get('track')),
        parent: this.model,
      });
      this.resplash.bind('splash:open', this.disableExpansion, this);
      this.resplash.bind('splash:close', this.enableExpansion, this);

      if (this.model.get('expanded')) {
        $(this.el).addClass('expanded');

        this.comments = new Events.Splash.Comments({
          el:         this.$('[data-widget = "comments"]').get(0),
          collection: this.model.comments()
        });

        this.comments.render();

        this.mentions = new UserMentions({
          el: this.$('.comment-text-area'),
          parent: this.el
        });

        this.share      = new Events.Splash.SocialSitePost({model: this.model});

          this.loadThumbnails();
      }

      $(this.el).find(".expand").each(function(){
        $(this).hasClass('comment-text-area') ? $(this).TextAreaExpander(12) : $(this).TextAreaExpander(70);
      });

      fixBG(this.$('.the_water, .noise-overlay, .numHolder, .numHolderCount'));

      return this;
    },

    reset: function() {
      this.$('textarea').val('');
    },

    renderThumbnails: function() {
      var ul   = $('<ul/>');
      var self = this;
      var header = '<div class="header_label avan-demi">Splash Lineage:</div>';

      this.siblings.each(function(s) {
        var li = $('<li/>').html($.tmpl(self.thumbTemplate, s.get('user')));

        if (s.get('user').id === self.options.currentUserID)
          li.addClass('highlight');

        ul.append(li);
      });
      this.$('[data-widget = "thumbnails"]').html(ul).removeClass('loading');
      this.$('[data-widget = "thumbnails"]').prepend(header);
    },
  }).mixin(Purchase);

  window.Events.Splash.Comments = Backbone.View.extend({
    template: $('#tmpl-event-splash-comment').template(),

    initialize: function() {
      _.bindAll(this, 'renderComment');

      this.collection.bind('add', this.renderComment, this);
    },

    render: function() {
      this.collection.each(this.renderComment);
    },

    renderComment: function(c) {
      var createdAt  = $.timeago(c.get('created_at'));
      var json       = _.extend(c.toJSON(), {created_at: createdAt});

      $(this.el).append($.tmpl(this.template, json));
    },
  });

  window.Events.Splash.SocialSitePost = Backbone.View.extend({
    el: '[data-widget = "social-site-post"]',

    events: {
      'click': 'share'
    },

    share: function(){
      var splash = this.model;

      splash.share($(this.el).attr('data-site'));
    }
  });

  window.Events.Settings = Backbone.View.extend({
    initialize: function() {
      _.bindAll(this, 'onChange', 'onToggleFollowing');

      var self = this;

      $('[data-widget = "filter-splash"],' +
        '[data-widget = "filter-other"]').each(function(__, e) {
          $(e).iphoneStyle(_.extend({onChange: self.onChange},
                                    $(e).data()));
        });

      $('[data-widget = "filter-following"] a').click(this.onToggleFollowing);

      if (this.options.filters.mentions) {
        // TODO: Find a better way to do this.
        $('[data-widget = "filter-following"] a[href = "#mentions"]').click();
      } else if (this.options.filters.everyone) {
        $('[data-widget = "filter-following"] a[href = "#everyone"]').click();
      }
    },

    disable: function() {
      var ff = $('[data-widget = "filter-following"]');

      $('li', ff).addClass('disabled');

      $(ff).block({
        message: null,
        overlayCSS: {opacity: 0}
      });
    },

    enable: function() {
      var ff = $('[data-widget = "filter-following"]');

      $('li', ff).removeClass('disabled');

      $(ff).unblock();
    },

    filters: function() {
      var settings = {
        mentions: '',
        splashes: 1,
        other:    '',
      };

      var everyone = $('[data-widget = "filter-following"] a[href = "#everyone"]');
      var mentions = $('[data-widget = "filter-following"] a[href = "#mentions"]');
      var social   = $('[data-widget = "filter-following"] a[href = "#social"]');

      if (everyone.hasClass('active')) {
        settings.user     = '';
        settings.follower = '';
      } else if (mentions.hasClass('active')) {
        settings.splashes = '';
        settings.other    = '';
        settings.mentions = 1;
      } else if (social.hasClass('active')) {
        settings.mentions = '';
        settings.splashes = '';
        settings.other    = 1;
      }

      return settings;
    },

    onChange: function() {
      this.trigger('change');
    },

    onToggleFollowing: function(e) {
      e.preventDefault();

      $('[data-widget = "filter-following"] li').removeClass('ui-tabs-selected');
      $('[data-widget = "filter-following"] a').removeClass('active');

      $(e.target).addClass('active');
      $(e.target).closest('li').first().addClass('ui-tabs-selected');

      this.onChange();
    },
  });

  window.Events.Filter = Backbone.View.extend({
    el: '[data-widget = "events-filter"]',
    events : {
      'click [data-widget = "toggle"]' : 'toggleFilter'
    },

    initialize: function() {
      this.filterView  = this.$('[data-widget = "filter"]');
      this.suggestions = this.$('[data-widget = "suggestions"]');
      this.tags        = [];

      _.bindAll(this, 'toggleFilter', 'onAdd', 'onRemove', 'onSuggestions');

      this.setupAutoSuggest();
    },

    filters: function() {
      return {tags: this.tags};
    },

    onAdd: function(e) {
      this.suggestions.hide();

      this.tags.push(this.textFrom(e));

      this.trigger('change');
    },

    onRemove: function(e) {
      this.tags = _.without(this.tags, this.textFrom(e));

      e.remove();

      this.trigger('change');
    },

    onSuggestions: function() {
      this.$('.as-results').prepend('<h4><span>Results</span></h4>');

      this.positionSuggestions();

      this.suggestions.show();
    },

    positionSuggestions: function() {
      var os = this.$('.comment-text-area').position();
      var l  = os.left + (this.$('.comment-text-area').width() / 2);

      this.suggestions.css('left', l + 'px');
    },

    setupAutoSuggest: function() {
      this.$('.comment-text-area').autoSuggest(Routes.tags_path(), {
        selectionRemoved: this.onRemove,
        selectionAdded: this.onAdd,
        resultsHighlight: false,
        resultsComplete: this.onSuggestions
      });

      $('.as-results').addClass('scroll-area').prependTo(this.$('.wrap'));
    },

    textFrom: function(e) {
      return $(e).contents().filter(function() {
        return this.nodeType == 3;
      }).text().trim();
    },

    toggleFilter: function() {
      this.filterView.toggle();

      if (this.filterView.is(':visible')) {
        $(this.el).height(HEIGHT_WHEN_OPEN);
      } else {
        $(this.el).height('auto');
      }
    }
  });
});
