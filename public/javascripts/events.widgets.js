$(function() {
  window.Events = Backbone.View.extend({
    el: '[data-widget = "events"]',
    templates: {
      splash: '#tmpl-event-splash'
    },

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'renderEvent');

      for (var k in this.templates) {
        this.templates[k] = $(this.templates[k]).template();
      }

      this.feed = new EventList;
      this.feed.bind('reset', this.render, this);
      this.feed.fetch({data: {user: this.currentUserId,
                              follower: this.currentUserId,
                              update_on_splash: true}})

      this.filter = new Events.Filter;
    },

    render: function() {
      $(this.el).empty();

      this.feed.each(this.renderEvent);
    },

    renderEvent: function(e) {
      $($.tmpl(this.templates[e.get('type')], e.toJSON())).appendTo(this.el);
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

      _.bindAll(this, 'toggleFilter', 'hideSuggestions', 'onSuggestions');

      this.setupAutoSuggest();
    },

    hideSuggestions: function() {
      this.suggestions.hide();
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
        selectionAdded: this.hideSuggestions,
        resultsHighlight: false,
        resultsComplete: this.onSuggestions
      });

      $('.as-results').addClass('scroll-area').prependTo(this.$('.wrap'));
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