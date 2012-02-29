TrackSearch = Search.extend({
  UPLOAD_BEGIN_POS: -625,
  UPLOAD_END_POS: -25,

  animation: new Animation('slide', {direction: 'up'}, 200),
  collection: new TrackList,
  el: '[data-widget = "track-search"]',
  events: _.extend({
    'click [data-widget = "toggle-upload"]': 'showUpload',
    'click [data-widget = "view-all-results"]': 'viewAllResults',
    'hiding': 'removeUploadProgressForm',
    'showing': 'prepareUploadProgressForm',
    'upload:done': 'onUploadDone',
    'upload:error': 'onUploadError',
    'upload:metadata': 'onMetadataSave',
    'upload:progress': 'onUploadProgress',
    'upload:splash': 'onUploadSplash',
    'upload:start': 'onUploadStart',
    'search:expand': 'hide',
  }, Search.prototype.events),
  extraParams: {popular: true},
  keepResults: true,
  maxBrowseablePages: 2,
  menuContainer: 'ul',

  initialize: function() {
    Search.prototype.initialize.call(this);

    this.input     = this.$('input.field');
    this.uploadBar = this.input;

    this.uploadStep =
      Math.abs(parseInt((this.UPLOAD_END_POS + this.UPLOAD_BEGIN_POS) / 100));

    this.upload = new Upload().render();
    this.$('.wrap').append(this.upload.hide().el);
  },

  disable: function() {
    $(this.el).block({
      message: null,
      overlayCSS: {opacity: 0}
    });

    this.$('input.field').attr('disabled', true);
    this.$('[data-widget = "toggle-upload"]').addClass('disabled');
  },

  enable: function() {
    this.$('input.field').attr('disabled', false);
    this.$('[data-widget = "toggle-upload"]').removeClass('disabled');

    $(this.el).unblock();
  },

  onUploadError: function() {
    this.uploadBar.addClass('error');
    this.uploadBar.val(I18n.t('upload.error'));
  },

  onMetadataSave: function() {
    this.uploadBar.val(I18n.t('upload.metadata'));
  },

  onUploadDone: function(e) {
    this.uploadBar.val(I18n.t('upload.done'));
  },

  onUploadProgress: function(_, data) {
    this.setUploadProgress(data.percent);
  },

  onUploadSplash: function() {
    this.uploadBar.val(I18n.t('upload.exists'));
  },

  onUploadStart: function() {
    this.uploadBar.removeClass('error');
    this.uploadBar.val(I18n.t('upload.start'));

    this.setUploadProgress(0);
  },

  open: function() {
    this.menu.find('li:last').addClass('last');
  },

  renderItem: function(i) {
    var opts = {model: i};

    $(new TrackSearch.Track(opts).render().el).appendTo(this.menu);
  },

  prepareUploadProgressForm: function() {
    this.uploadBar.removeClass('error');
    this.uploadBar.addClass('uploading')
    this.uploadBar.attr('disabled','true');
    this.uploadBar.attr('value', I18n.t('upload.waiting'));

    this.setUploadProgress(0);
  },

  removeUploadProgressForm: function() {
    this.uploadBar.removeClass('uploading')
    this.uploadBar.removeAttr('disabled','disabled');
    this.uploadBar.attr('value','');
  },

  setUploadProgress: function(percent) {
    var pos = this.UPLOAD_BEGIN_POS + percent * this.uploadStep;

    this.uploadBar.css('background-position', pos + 'px 0');
  },

  showUpload: function(e) {
    e.stopPropagation();

    this.upload.show();
  },

  viewAllResults: function() {
    $(this.el).trigger('search:expand', {terms: this.term()});
  },
});

TrackSearch.Track = Backbone.View.extend({
  events: {
    'click [data-widget = "play"]': 'play'
  },
  tagName: 'li',

  play: function(e) {
    e.preventDefault();

    $(this.el).trigger('request:play',
                       {track: this.model.toJSON()});
  },

  render: function() {
    $(this.el).attr('data-track_id', this.model.get('id'));
    $(this.el).html($.tmpl(this.template, this.model.toJSON()));

    new FullSplashAction({
      model: this.model,
      el: this.$('[data-widget = "full-splash-action"]').get(0),
    });

    return this;
  },
});

window.TrackSearch.AllResults = Backbone.View.extend({
  className: 'all-results',
  events: {
    'click [data-widget = "close"]': 'close',
    'splash:splash': 'close',
    'search:loaded': 'resize',
  },

  initialize: function() {
    this.table = new TrackSearch.AllResults.Results;

    $(this.el).hide();

    this.animation = new Animation('slide', {direction: 'left'}, 500);
  },

  close: function() {
    $(this.el).trigger('search:collapse');

    this.animation.hide(this.el, function() {
      $(this.el).detach();

      this.table.clear();
    }, this);
  },

  load: function(searchTerms) {
    this.setHeader(searchTerms)

    $(this.el).css('height', '100%');

    this.animation.show(this.el, _.bind(function() {
      this.table.load(searchTerms);
    }, this));

    return this;
  },

  render: function() {
    $(this.el).html($.tmpl(this.template));
    $(this.el).append(this.table.el);

    return this;
  },

  resize: function() {
    if (this.$('table').height() > $(this.el).height()) {
      $(this.el).css('height', 'auto');
    }
  },

  setHeader: function(searchTerms) {
    this.$('h2').text(I18n.t('all_results.header', {terms: searchTerms}));
  },
});

window.TrackSearch.AllResults.Results = Backbone.View.extend({
  tagName: 'table',

  initialize: function() {
    this.collection = new TrackList;
    this.collection.bind('reset', this.addRanks, this);
    this.collection.bind('reset', this.reset, this);
  },

  addRanks: function(collection) {
    var idxs = _.range(collection.length);

    _(collection.toArray()).
      chain().
      zip(idxs).
      each(function(mi) { mi[0].set({rank: mi[1] + 1}); });
  },

  clear: function() {
    this.$('tbody').empty();
  },

  load: function(searchTerms) {
    this.collection.fetch({data: {with_text: searchTerms}});
  },

  render: function() {
    $(this.el).html($.tmpl(this.template));

    var $tbody = this.$('tbody');

    this.collection.each(function(m) {
      var v = new TrackSearch.AllResults.Result({model: m});

      $tbody.append(v.render().el);
    }, this);

    return this;
  },

  reset: function() {
    this.clear();

    this.render();

    $(this.el).trigger('search:loaded');
  },
});

window.TrackSearch.AllResults.Result = Backbone.View.extend({
  events: {
    'click': 'clicked',
  },
  tagName: 'tr',

  clicked: function(e) {
    if (! $(e.target).is('[data-widget = "toggle-splash"]')) this.play();
  },

  play: function() {
    $(this.el).trigger('request:play',
                       {track: this.model.toJSON()});
  },

  render: function() {
    $(this.el).html($.tmpl(this.template, this.model.toJSON()));

    this.splash = new FullSplashAction({
      model: this.model,
      el: $.tmpl(this.templateSplash).get(0),
    });

    $(this.splash.el).live('splash:splash', _.bind(this.toggleSplash, this));

    this.toggle   = new Toggle({
      el:        this.$('[data-widget = "toggle-splash"]'),
      target:    this.splash.el,
      isEnabled: this.model.get('splashable'),
      doToggle:  _.bind(this.toggleSplash, this),
    });

    return this;
  },

  toggleSplash: function() {
    if ($(this.splash.el).is(':visible')) {
      $(this.el).removeClass('splashing');
      $(this.splash.el).detach();
    } else {
      $(this.el).addClass('splashing');
      $(this.el).after(this.splash.el);
    }
  },
});

$(function() {
  TrackSearch.Track.prototype.template = $('#tmpl-home-track').template();
  TrackSearch.AllResults.prototype.template =
    $('#tmpl-track-search-all-results').template();
  TrackSearch.AllResults.Results.prototype.template =
    $('#tmpl-track-search-all-results-table').template();
  TrackSearch.AllResults.Result.prototype.template =
    $('#tmpl-track-search-all-results-table-row').template();
  TrackSearch.AllResults.Result.prototype.templateSplash =
    $('#tmpl-all-results-splash').template();
});