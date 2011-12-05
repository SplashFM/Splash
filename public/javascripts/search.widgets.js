$(function() {
  window.Search = Backbone.View.extend({
    container: '[data-widget = "results"]',

    delay: 500,

    events: {
      'keyup :text': 'maybeSearch',
      'click [data-widget = "load-more"]': 'loadMoreResults',
      'submit': 'maybeSearch',
    },

    initialize: function(opts) {
      _.extend(this, opts);

      this.container = this.$(this.container);
      this.menu      = this.$(this.menuContainer || this.container);
      this.template  = $(this.template).template();
      this.page      = 1;

      _.bindAll(this, 'hide', 'search', 'loadMoreResults',
                      'renderItem', 'renderLoadMoreResults');

      this.$(':text').attr('autocomplete', 'off');

      this.collection.bind('reset', this.render, this);
      this.collection.bind('add', this.renderItem, this);

      $(this.el).clickout(this.hide);

      $(this.el).bind('splash:splash', this.hide);
    },

    hide: function() {
      this.$('[data-widget = "load-more"]').hide();
      this.$('[data-widget = "empty"]').hide();
      $(this.container).hide();
    },

    isSearchable: function() {
      return this.term().length > 0 && this.lastTerm !== this.term();
    },

    loadMoreResults: function(e) {
      e.preventDefault();

      this.page++;

      this.$('[data-widget = "load-more"]').hide();

      this.collection.
        fetch({data: {page: this.page, with_text: this.term()}}).
        done(this.renderLoadMoreResults);
    },

    maybeSearch: function() {
      if (this.timeout) clearTimeout(this.timeout);

      this.timeout  = setTimeout(this.search, this.delay);
      return false;
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
      Widgets.Scroll.init();
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

