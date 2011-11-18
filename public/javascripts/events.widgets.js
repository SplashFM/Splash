$(function() {
  window.Events = Backbone.View.extend({
    el: '[data-widget = "events"]',
    updateInterval: 60000, // 1 minute

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'checkForUpdates', 'onSplash', 'refresh', 'renderEvent',
                      'renderUpdateCount', 'scroll');

      $('body').bind('splash:splash', this.onSplash)
      $('body').bind('upload:complete', this.onSplash)

      this.feed = new EventList;
      this.feed.bind('reset', this.render, this);
      this.feed.bind('add', this.renderEvent, this);

      this.filterView = new Events.Filter;
      this.filterView.bind('change', this.refresh, this);

      this.settings = new Events.Settings({currentUserId: this.currentUserId});
      this.settings.bind('change', this.refresh, this);

      this.currentInterval = setInterval(this.checkForUpdates,
                                         this.updateInterval);
      if (this.app) {
        this.app.bind('endlessScroll', this.scroll, this)
      }

      this.refresh();
    },

    allFilters: function() {
      return _.extend({}, this.options.filters,
                          this.filterView.filters(),
                          this.settings.filters())
    },

    checkForUpdates: function() {
      this.feed.updateCount(this.allFilters(), this.renderUpdateCount);
    },

    fetch: function(add) {
      this.feed.fetch({add:  add,
                       data: _.extend({page: this.page}, this.allFilters())});
    },

    onSplash: function() {
      this.refresh();
    },

    refresh: function() {
      this.page = 1;

      this.fetch();
    },

    render: function() {
      $(this.el).empty();

      this.feed.each(this.renderEvent);
    },

    renderEvent: function(e) {
      switch (e.get('type')) {
      case 'splash':
        $(this.el).append(new Events.Splash({model: e}).render().el);
        break;
      case 'relationship':
      case 'comment':
        $(this.el).append(new Events.Social({model: e}).render().el);
        break;
      default:
      }
    },

    renderUpdateCount: function(count) {
      $('[data-widget = "update-count"]').
        text(I18n.t('events.updates', {count: count}))
    },

    scroll: function() {
      this.page++;

      this.fetch(true);
    },
  });

  window.Events.Social = Backbone.View.extend({
    tagName: 'li',
    className: 'feed-socials',
    templates: {
      relationship: $('#tmpl-event-relationship').template(),
      comment: $('#tmpl-event-comment').template(),
    },

    render: function() {
      $(this.el).html($.tmpl(this.templates[this.model.get('type')],
                             this.model.toJSON()));

      return this;
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
      'click [data-widget = "play"]': 'play'
    },
    tagName: 'li',
    template: $('#tmpl-event-splash').template(),

    initialize: function() {
      _.bindAll(this, 'reset');

      this.model.bind('change', this.render, this);
    },

    addComment: function(e) {
      e.preventDefault();

      this.model.comments().create({
        body: this.mentions.commentWithMentions()
      }, {
        success: this.reset
      });
    },

    toggleExpanded: function(e) {
      if (!e ||
          (($(e.target).closest('[data-widget = "expand"]').length > 0 ||
            $(e.target).closest('a').length == 0) &&
           $(e.target).closest('[data-widget = "more-info"]').length === 0)) {
        if (e) e.preventDefault();

        if (this.$('[data-widget = "more-info"]').length === 0) {
          this.model.fetch();
        } else {
          this.$('[data-widget = "more-info"]').toggle();
        }
      }
    },

    play: function(e) {
      e.preventDefault();

      $(this.el).trigger('request:play',
                         {track: this.model.get('track')});
    },

    render: function() {
      var s          = this.model;
      var commentStr = I18n.t('comments', {count: s.get('comments_count')});
      var createdAt  = $.timeago(s.get('created_at'));
      var ext        = {created_at: createdAt, comment_count: commentStr};
      var json       = _.extend(s.toJSON(), ext);

      $(this.el).html($.tmpl(this.template, json));
      SPLASH.Widgets.numFlipper($('.the_splash_count',this.el));

      new BaseApp.ReSplashAction({
        el: this.$('[data-widget = "splash-action"]'),
        model: this.model
      });

      if (this.model.get('expanded')) {
        $(this.el).addClass('expanded');

        this.comments = new Events.Splash.Comments({
          el:         this.$('[data-widget = "comments"]').get(0),
          collection: this.model.comments()
        });

        this.comments.render();

        this.mentions = new UserMentions({el: this.$(':text'), parent: this.el});
      }

      return this;
    },

    reset: function() {
      this.mentions.reset();
      this.$(':text').val('');

      this.toggleExpanded();

      // fetch doesn't clear existing attributes
      this.model.unset('expanded', {silent: true});

      this.model.fetch({data: {summary: true}});
    },
  })

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
    },

    filters: function() {
      return this.settings;
    },

    onChange: function() {
      var settings = {
        omit_splashes: $('[data-widget = "filter-splash"]').is(":checked") ? '' : true,
        omit_other:    $('[data-widget = "filter-other"]').is(":checked") ? '' : true,
      };

      var everyone = $('[data-widget = "filter-following"] a[href = "#everyone"]');
      if (everyone.hasClass('active')) {
        settings.user     = '';
        settings.follower = '';
      }

      this.settings = settings;

      this.trigger('change');
    },

    onToggleFollowing: function(e) {
      var active   = $('[data-widget = "filter-following"] a.active');
      var inactive = $('[data-widget = "filter-following"] a:not(.active)');

      if (active.attr('href') != $(e.target).attr('href')) {
        active.removeClass('active');
        active.parent().removeClass('ui-tabs-selected');

        inactive.addClass('active');
        inactive.parent().addClass('ui-tabs-selected');

        this.onChange();
      }
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
      var os = this.$(':text').position();
      var l  = os.left + (this.$(':text').width() / 2);

      this.suggestions.css('left', l + 'px');
    },

    setupAutoSuggest: function() {
      this.$(':text').autoSuggest(Routes.tags_path(), {
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