$(function() {
  window.Search = Backbone.View.extend({
    animation: NilAnimation,

    container: '[data-widget = "results"]',

    events: {
      'keyup :text': 'maybeSearch',
      'click [data-widget = "load-more"]': 'loadMoreResults',
      'submit': 'cancel',
    },

    cancel: function(e){
      e.preventDefault();
    },

    initialize: function(opts) {
      _.extend(this, opts);

      this.container = this.$(this.container);
      this.menu      = this.$(this.menuContainer || this.container);
      this.template  = $(this.template).template();
      this.searching = {readyState: 4};

      _.bindAll(this, 'hide', 'search', 'loadMoreResults',
                      'renderItem', 'renderControls');

      this.$(':text').attr('autocomplete', 'off');

      this.collection.bind('reset', this.render, this);
      this.collection.bind('add', this.renderItem, this);

      $(this.el).clickout(this.hide);

      $(this.el).bind('splash:splash', this.hide);
    },

    cancelPreviousSearch: function() {
      if (this.searching.readyState < 4) this.searching.abort();
    },

    doneLoading: function() {
      this.$(':text').removeClass('loading');
    },

    fetchResults: function() {
      this.loading();

      var data = {page: this.page, with_text: this.term()};

      return this.collection.fetch({data: _.extend(data, this.extraParams)});
    },

    hide: function() {
      if (this.container.is(':visible')) {
        this.$('.controls').hide();
        this.$('[data-widget = "empty"]').hide();
        this.animation.hide(this.container);
      }
    },

    isSearchable: function() {
      return this.term().length > 0 && this.lastTerm !== this.term();
    },

    loading: function() {
      this.$(':text').addClass('loading');
    },

    loadMoreResults: function(e) {
      e.preventDefault();

      this.page++;

      this.$('.controls').hide();

      this.fetchResults();
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

      this.doneLoading();

      this.renderControls();
      if (! $(this.container).is(':visible')) {
        this.animation.show(this.container);
      }

      Widgets.Scroll.init();
    },

    renderItem: function(i) {
      return $($.tmpl(this.template, i.toJSON())).appendTo(this.menu);
    },

    renderControls: function() {
      if (this.collection.hasFullPages(this.options.perPage)) {
        var mbp = this.maxBrowseablePages;

        if (mbp && this.page > mbp) {
          this.$('[data-widget = "load-more"]').hide();
        } else {
          this.$('[data-widget = "load-more"]').show();
        }

        this.$('.controls').show();
      } else {
        this.$('.controls').hide();
      }
    },

    search: function() {
      if (this.isSearchable()) {
        this.cancelPreviousSearch();

        this.page      = 1;
        this.lastTerm  = this.term();
        this.searching = this.fetchResults();
      }
    },

    term: function() {
      return this.$(':text').val();
    }
  });
});
