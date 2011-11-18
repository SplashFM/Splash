$(function() {
  TrackSearch = Search.extend({
    UPLOAD_BEGIN_POS: -625,
    UPLOAD_END_POS: -25,

    collection: new TrackList,
    el: '[data-widget = "track-search"]',
    events: _.extend({
      'click [data-widget = "toggle-upload"]': 'showUpload',
      'hiding': 'removeUploadProgressForm',
      'showing': 'prepareUploadProgressForm',
      'upload:done': 'onUploadDone',
      'upload:error': 'onUploadError',
      'upload:metadata': 'onMetadataSave',
      'upload:progress': 'onUploadProgress',
      'upload:start': 'onUploadStart'
    }, Search.prototype.events),
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
  });

  TrackSearch.Track = Backbone.View.extend({
    events: {
      'click [data-widget = "play"]': 'play'
    },
    tagName: 'li',
    template: $('#tmpl-home-track').template(),

    play: function(e) {
      e.preventDefault();

      $(this.el).trigger('request:play',
                         {track: this.model.toJSON()});
    },

    render: function() {
      $(this.el).attr('data-track_id', this.model.get('id'));
      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      new TrackSearch.Track.FullSplashAction({
        model: this.model,
        el: this.$('[data-widget = "full-splash-action"]').get(0),
      });

      return this;
    },
  });

  TrackSearch.Track.FullSplashAction = BaseApp.SplashAction.extend({
    events: {
      'click [data-widget = "toggle-splash"]': 'toggle',
      'submit form': 'splash'
    },

    initialize: function() {
      BaseApp.SplashAction.prototype.initialize.call(this);

      _.bindAll(this, 'finishSplash');
      this.mentions = new UserMentions({el: this.$('form textarea'),
                                        parent: this.el});
    },

    splash: function(e) {
      e.preventDefault();

      new Splash().save({
        comment:  this.mentions.commentWithMentions(),
        track_id: this.model.get('id')
      }, {
        success: this.finishSplash
      });
    },

    toggle: function(e) {
      e.preventDefault();
      if (this.model.get('splashable')) {
        this.$('form').toggle();
      }
    },

    finishSplash: function() {
      this.$('form').hide();
      // FIXME: neither of these seem to actually trigger a rerender of the single view.
      this.broadcastSplash();
      this.model.change();
    }
  });

  Upload = Backbone.View.extend({
    className: 'uploadForm',
    events: {'upload:complete': 'hide'},
    tagName: 'div',
    template: $('#tmpl-upload').template(),

    initialize: function() {
      _.bindAll(this, 'hide', 'onError', 'onProgress', 'onStart', 'onUpload');
      _this = this;
      $(this.el).clickout(this.hide);
    },

    hide: function(args) {
      $(this.el).hide();
      $(this.el).trigger("hiding");

      return this;
    },

    onProgress: function(_, data) {
      $(this.el).trigger('upload:progress', {
        percent: parseInt(data.loaded / data.total * 100)
      });
    },

    onError: function() {
      $(this.el).trigger('upload:error');
    },

    onStart: function() {
      $(this.el).trigger('upload:start');
    },

    onUpload: function(_, data) {
      $(this.el).trigger('upload:done');

      this.metadata.setModel(new UndiscoveredTrack(data.result));
    },

    render: function() {
      $(this.el).append($.tmpl(this.template));

      this.$('form').fileupload({
        progress: this.onProgress,
        start: this.onStart,
        done: this.onUpload,
        fail: this.onError
      });

      this.metadata = new Upload.Metadata({model: this.model});

      $(this.el).append(this.metadata.render().el);

      return this;
    },

    show: function() {
      $(this.el).show();

      $(this.el).trigger('showing');

      return this;
    },
  });

  Upload.Metadata = Backbone.View.extend({
    events: {'submit': 'onSubmit'},
    tagName: 'form',
    template: $('#tmpl-upload-metadata').template(),

    initialize: function() {
      _.bindAll(this, 'onComplete', 'onSubmit');
    },

    onComplete: function() {
      this.$('[name = "title"]').val('');
      this.$('[name = "performers"]').val('');
      this.$('[name = "albums"]').val('');

      this.mentions.reset();

      $(this.el).trigger('upload:complete');

      this.$('[data-widget = "metadata"]').hide();
    },

    onSubmit: function(e) {
      e.preventDefault();

      var attrs = {
        title: this.$('[name = "title"]').val(),
        performers: this.$('[name = "performers"]').val(),
      }

      $(this.el).trigger('upload:metadata');

      this.model.save(attrs, {success: this.onComplete});
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.mentions = new UserMentions({el: this.$('textarea'),
                                        parent: this.el});
      return this;
    },

    setModel: function(model) {
      this.model = model;

      this.$('[name = "title"]').val(model.get('title'));
      this.$('[name = "performers"]').val(model.get('performers'));
      this.$('[name = "albums"]').val(model.get('albums'));

      this.$('[data-widget = "metadata"]').show();
    },
  });
});