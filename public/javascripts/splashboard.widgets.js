$(function() {

  window.Splashboard = {}
  Splashboard.Items = Backbone.View.extend({
    tagName: "ul",
    className: "splashboard-items",

    initialize: function(opts) {
      _.extend(this, opts);

      _.bindAll(this, 'scroll', 'renderItem');

      this.app         = opts.app;
      this.pageFilters = {user: this.currentUserId,
                          follower: this.currentUserId,
                          update_on_splash: true}
      this.userFilters = {};

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
                                      this.allFilters())});
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
      var json = s.toJSON();
      $($.tmpl(this.template, json)).appendTo(this.el);
    },
  });
});
