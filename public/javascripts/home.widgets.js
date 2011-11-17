$(function() {
  TrackSearch = Search.extend({
    UPLOAD_BEGIN_POS: -625,
    UPLOAD_END_POS: -25,

    collection: new TrackList,
    el: '[data-widget = "track-search"]',
    events: _.extend({
      'click [data-widget = "toggle-upload"]': 'showUpload'
    }, Search.prototype.events),
    menuContainer: 'ul',

    initialize: function() {
      Search.prototype.initialize.call(this);

      _.bindAll(this, 'onUploadProgress', 'onUploadStart',
                      'prepareUploadProgressForm', 'removeUploadProgressForm');

      this.input     = this.$('input.field');
      this.uploadBar = this.input;

      this.uploadStep =
        Math.abs(parseInt((this.UPLOAD_END_POS + this.UPLOAD_BEGIN_POS) / 100));

      this.upload = new Upload().render();
      this.$('.wrap').append(this.upload.hide().el);
      this.upload.bind('hiding',this.removeUploadProgressForm);
      this.upload.bind('showing',this.prepareUploadProgressForm);
      this.upload.bind('upload:progress',this.onUploadProgress);
      this.upload.bind('upload:start',this.onUploadStart);
    },

    onUploadProgress: function(e) {
      this.setUploadProgress(e.percent);
    },

    onUploadStart: function() {
      this.uploadBar.val(I18n.t('upload.start'));
    },

    open: function() {
      this.menu.find('li:last').addClass('last');
    },

    renderItem: function(i) {
      var opts = {model: i};

      $(new TrackSearch.Track(opts).render().el).appendTo(this.menu);
    },

    prepareUploadProgressForm: function() {
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
    tagName: 'li',
    template: $('#tmpl-home-track').template(),

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
      _.bindAll(this, 'hide', 'onProgress', 'onStart', 'onUpload');
      _this = this;
      $(this.el).clickout(this.hide);
    },

    hide: function(args) {
      $(this.el).hide();
      this.mentions.reset();
      this.trigger("hiding");

      return this;
    },

    onProgress: function(_, data) {
      this.trigger('upload:progress', {
        percent: parseInt(data.loaded / data.total * 100)
      });
    },

    onStart: function() {
      this.trigger('upload:start');
    },

    onUpload: function(_, data) {
      this.metadata.setModel(new UndiscoveredTrack(data.result));
    },

    render: function() {
      $(this.el).append($.tmpl(this.template));

      this.$('form').fileupload({
        progress: this.onProgress,
        start: this.onStart,
        done: this.onUpload,
      });

      this.metadata = new Upload.Metadata({model: this.model});

      $(this.el).append(this.metadata.render().el);

      this.mentions = new UserMentions({el: this.$('form textarea'),
                                        parent: this.el});

      return this;
    },

    show: function() {
      $(this.el).show();

      this.trigger('showing');

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
      $(this.el).trigger('upload:complete');
    },

    onSubmit: function(e) {
      e.preventDefault();

      var attrs = {
        title: this.$('[name = "title"]').val(),
        performers: this.$('[name = "performers"]').val(),
      }

      this.model.save(attrs, {success: this.onComplete});
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

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