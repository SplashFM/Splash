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
      this.filter = this.$('[data-widget = "filter"]');

      _.bindAll(this, 'toggleFilter');
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