$(function() {
  window.Search = Backbone.View.extend({
    container: '[data-widget = "results"]',

    delay: 500,

    events: {
      'keyup :text': 'maybeSearch',
      'click [data-widget = "load-more"]': 'loadMoreResults'
    },

    initialize: function(opts) {
      _.extend(this, opts);

      this.container = this.$(this.container);
      this.menu      = this.$(this.menuContainer || this.container);
      this.template  = $(this.template).template();
      this.page      = 1;

      _.bindAll(this, 'search', 'loadMoreResults', 'renderItem',
                      'renderLoadMoreResults');

      this.collection.bind('reset', this.render, this)
      this.collection.bind('add', this.renderItem, this)
    },

    isSearchable: function() {
      return this.term().length > 0 && this.lastTerm !== this.term();
    },

    loadMoreResults: function(e) {
      e.preventDefault();

      this.page++;

      this.$('[data-widget = "load-more"]').hide();

      this.collection.fetch({data: {page: this.page, with_text: this.term()},
                             add: true}).
        done(this.renderLoadMoreResults);
    },

    maybeSearch: function() {
      if (this.timeout) clearTimeout(this.timeout);

      this.timeout  = setTimeout(this.search, this.delay);
    },

    render: function() {
      this.menu.empty();

      if (this.collection.length !== 0) {
        this.$('[data-widget = "empty"]').hide();

        this.collection.each(this.renderItem);
      } else {
        this.$('[data-widget = "empty"]').show();
      }

      if (this.open) this.open.call(this);

      this.container.show();
    },

    renderItem: function(i) {
      return $($.tmpl(this.template, i.toJSON())).appendTo(this.menu);
    },

    renderLoadMoreResults: function() {
      if (this.collection.hasFullPages(this.perPage)) {
        this.$('[data-widget = "load-more"]').show();
      } else {
        this.$('[data-widget = "load-more"]').hide();
      }
    },

    search: function() {
      if (this.isSearchable()) {
        this.lastTerm = this.term();

        this.collection.fetch({data: {with_text: this.term()}});
      }
    },

    term: function() {
      return this.$(':text').val();
    }
  });
});
