$(function() {
  window.Events = Backbone.View.extend({
    el: '[data-widget = "events"]',
    updateInterval: 6000, // 1 minute
    templates: {
      splash: $('#tmpl-event-splash').template()
    },

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
                       data: _.extend({}, this.allFilters())});
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
      var commentStr = I18n.t('comments', {count: e.get('comments_count')});

      $($.tmpl(this.templates[e.get('type')],
               _.extend({created_at_dist: $.timeago(e.get('created_at')),
                         comment_count:   commentStr},
                        e.toJSON()))).appendTo(this.el);
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