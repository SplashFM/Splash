$(function() {
  window.Search = Backbone.View.extend({
    animation: NilAnimation,

    container: '[data-widget = "results"]',

    events: {
      'keyup :text': 'maybeSearch',
      'submit': 'cancel',
    },

    cancel: function(e){
      e.preventDefault();
    },

    initialize: function(opts) {
      _.extend(this, opts);

      this.container       = this.$(this.container);
      this.menu            = this.$(this.menuContainer || this.container);
      this.template        = $(this.template).template();
      this.searching       = [];

      _.bindAll(this, 'hide', 'search', 'renderItem', 'renderControls',
                      'resultsLoaded');

      this.$(':text').attr('autocomplete', 'off');

      this.collection.bind('reset', this.render, this);

      $(this.el).clickout(this.hide);

      $(this.el).bind('splash:splash', this.hide);
    },

    cancelPreviousSearch: function() {
      if (this.searching.readyState < 4)
        _.each(this.searching, function(s) { s.abort(); });
    },

    doneLoading: function() {
      this.$(':text').removeClass('loading');
    },

    fetchResults: function() {
      this.loading();

      var data = _.extend({with_text: this.term()}, this.extraParams);
      var xhr  = this.collection.fetch({data: data, silent: true});

      xhr.done(this.resultsLoaded);

      this.searching.push(xhr);
    },

    hide: function() {
      this.searching = [];

      if (this.container.is(':visible')) {
        this.$('.controls').hide();
        this.$('[data-widget = "empty"]').hide();
        this.animation.hide(this.container);
      }
    },

    isRefinement: function() {
      return this.term().indexOf(this.lastTerm) == 0;
    },

    isSearchable: function() {
      return this.term().length > 0 && this.lastTerm !== this.term();
    },

    loading: function() {
      this.$(':text').addClass('loading');
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
        this.$('.controls').show();
      } else {
        this.$('.controls').hide();
      }
    },

    resultsLoaded: function(models) {
      var r = _.find(this.searching.slice(0).reverse(), function(e) {
        return e.readyState == 4 &&
               (this.keepResults ? $.parseJSON(e.responseText).length > 0 : 1);
      }, this);

      if (r) this.useResults($.parseJSON(r.responseText));

      this.render();
    },

    search: function() {
      if (this.isSearchable()) {
        if (this.cancelableSearch) this.cancelPreviousSearch();
        if (! this.isRefinement()) this.searching = [];

        this.lastTerm = this.term();

        this.fetchResults();
      }
    },

    term: function() {
      return this.$(':text').val();
    },

    useResults: function(models) {
      this.collection.reset(models);
    },
  });
});
