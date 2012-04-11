window.Search = Backbone.View.extend({
  animation: NilAnimation,

  container: '[data-widget = "results"]',

  events: {
    'keyup :text': 'termsChanged',
    'submit': 'cancel',
  },

  cancel: function(e){
    e.preventDefault();
  },

  initialize: function(opts) {
    _.extend(this, opts);

    this.container       = this.$(this.container);
    this.lastTerm        = "";
    this.menu            = this.$(this.menuContainer || this.container);
    this.searching       = [];

    _.bindAll(this, 'hide', 'search', 'renderItem', 'renderControls',
                    'resultsLoaded');

    this.$(':text').attr('autocomplete', 'off');

    this.collection.bind('reset', this.render, this);
    this.collection.bind('reset', this.doneLoading, this);

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
      this.hideContainer();
    }

    this.$el.trigger('search:hide');
  },

  hideContainer: function() {
    this.$('.controls').hide();
    this.$('[data-widget = "empty"]').hide();
    this.animation.hide(this.container);
  },

  isRelated: function() {
    return this.term().indexOf(this.lastTerm) == 0 ||
           this.lastTerm.indexOf(this.term()) == 0;
  },

  isSearchable: function() {
    return this.term().length > 0 && ! this.sameTerms();
  },

  loading: function() {
    this.$(':text').addClass('loading');
  },

  termsChanged: function() {
    if (this.timeout) clearTimeout(this.timeout);

    if (this.sameTerms()) return false;

    if (this.term().length === 0) {
      this.trigger('reset');

      return false;
    }

    if (this.isSearchable()) {
      this.lastTerm = this.term()

      this.timeout = setTimeout(this.search, this.delay);
    }

    return false;
  },

  render: function() {
    this.menu.empty();

    this.collection.each(this.renderItem);

    if (this.open) this.open.call(this);

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
    this.$('.controls').show();
  },

  resultsLoaded: function(models) {
    var r = _.find(this.searching.slice(0).reverse(), function(e) {
      return e.readyState == 4 &&
             (this.keepResults ? $.parseJSON(e.responseText).length > 0 : 1);
    }, this);

    if (r) this.useResults($.parseJSON(r.responseText));

    this.render();
  },

  sameTerms: function() {
    return this.term() === this.lastTerm;
  },

  search: function() {
    this.$(':text').attr('autocomplete', 'off');

    if (this.cancelableSearch) this.cancelPreviousSearch();
    if (! this.isRelated()) this.searching = [];

    this.fetchResults();
  },

  term: function() {
    return $.trim(this.$(':text').val());
  },

  useResults: function(models) {
    this.collection.reset(models);
  },
});
