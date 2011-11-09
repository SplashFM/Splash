$(function() {
  window.Events = Backbone.View.extend({
    el: '[data-widget = "events"]',
    updateInterval: 60000, // 1 minute

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'checkForUpdates', 'refresh', 'renderEvent',
                      'renderUpdateCount', 'scroll');

      this.pageFilters = {user: this.currentUserId,
                          follower: this.currentUserId,
                          update_on_splash: true}

      this.feed = new EventList;
      this.feed.bind('reset', this.render, this);
      this.feed.bind('add', this.renderEvent, this);

      this.fetch();

      this.filter = new Events.Filter;
      this.filter.bind('change', this.refresh, this);

      this.page = 1;

      this.currentInterval = setInterval(this.checkForUpdates,
                                         this.updateInterval);
    },

    allFilters: function() {
      return _.extend({}, this.pageFilters, this.userFilters);
    },

    checkForUpdates: function() {
      this.feed.updateCount(this.allFilters(), this.renderUpdateCount);
    },

    fetch: function(add) {
      this.feed.fetch({add:  add,
                       data: _.extend({page: this.page},
                                      this.allFilters())});
    },

    refresh: function(filters) {
      this.page        = 1;
      this.userFilters = filters;

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

  var HEIGHT_WHEN_OPEN = 62;

  window.Events.Splash = Backbone.View.extend({
    events: {
      'click [data-widget = "expand"]': 'expand',
      'submit [data-widget = "comment-box"]': 'addComment'
    },
    tagName: 'li',
    template: $('#tmpl-event-splash').template(),

    initialize: function() {
      this.model.bind('change', this.render, this);
    },

    addComment: function(e) {
      e.preventDefault();

      this.model.comments().create({body: this.$(':text').val()});

      this.$(':text').val('');
    },

    expand: function(e) {
      e.preventDefault();

      this.model.fetch();
    },

    render: function() {
      var s          = this.model;
      var commentStr = I18n.t('comments', {count: s.get('comments_count')});
      var json       = _.extend({created_at_dist: $.timeago(s.get('created_at')),
                                 comment_count:   commentStr},
                                s.toJSON());

      $(this.el).attr('data-widget', 'splash');
      $(this.el).attr('data-track_id', this.model.get('track').id);

      $(this.el).html($.tmpl(this.template, json).html());

      if (this.model.get('expanded')) {
        $(this.el).addClass('expanded');

        this.comments = new Events.Splash.Comments({
          el:         this.$('[data-widget = "comments"]').get(0),
          collection: this.model.comments()
        });

        this.comments.render();
      }

      return this;
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
      $(this.el).append($.tmpl(this.template, c.toJSON()));
    },
  });

  window.Events.Filter = Backbone.View.extend({
    el: '[data-widget = "events-filter"]',
    events : {
      'click [data-widget = "toggle"]' : 'toggleFilter'
    },

    initialize: function() {
      this.filter      = this.$('[data-widget = "filter"]');
      this.suggestions = this.$('[data-widget = "suggestions"]');
      this.tags        = [];

      _.bindAll(this, 'toggleFilter', 'onAdd', 'onRemove', 'onSuggestions');

      this.setupAutoSuggest();
    },

    onAdd: function(e) {
      this.suggestions.hide();

      this.tags.push(this.textFrom(e));

      this.trigger('change', {tags: this.tags});
    },

    onRemove: function(e) {
      this.tags = _.without(this.tags, this.textFrom(e));

      e.remove();

      this.trigger('change', {tags: this.tags});
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
      this.filter.toggle();

      if (this.filter.is(':visible')) {
        $(this.el).height(HEIGHT_WHEN_OPEN);
      } else {
        $(this.el).height('auto');
      }
    }
  });
});