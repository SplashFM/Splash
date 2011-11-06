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
    },

    render: function() {
      $(this.el).empty();

      this.feed.each(this.renderEvent);
    },

    renderEvent: function(e) {
      $($.tmpl(this.templates[e.get('type')], e.toJSON())).appendTo(this.el);
    }
  });
});