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
      'upload:splash': 'onUploadSplash',
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

      new FullSplashAction({
        model: this.model,
        el: this.$('[data-widget = "full-splash-action"]').get(0),
      });

      return this;
    },
  });

  Upload = Backbone.View.extend({
    className: 'uploadForm',
    events: {'upload:complete': 'hide'},
    tagName: 'div',
    template: $('#tmpl-upload').template(),

    initialize: function() {
      _.bindAll(this, 'hide', 'onError', 'onProgress', 'onStart', 'onUpload');
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
      switch (data.jqXHR.status) {
      case 201:
        this.metadata.setModel(new UndiscoveredTrack(data.result), 'edit');

        $(this.el).trigger('upload:done');

        break;
      case 200:
        this.metadata.setModel(new UndiscoveredTrack(data.result), 'splash');

        $(this.el).trigger('upload:splash');

        break;
      }
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
      this.$('textarea').val('');

      $(this.el).trigger('upload:complete');

      this.$('[data-widget = "metadata"]').hide();
      this.$('[data-widget = "complete-upload"]').hide();
    },

    onSubmit: function(e) {
      e.preventDefault();

      if (this.mode == 'edit') {
        var attrs = {
          albums: this.$('[name = "albums"]').val(),
          comment: this.comment.comment(),
          title: this.$('[name = "title"]').val(),
          performers: this.$('[name = "performers"]').val(),
        }

        $(this.el).trigger('upload:metadata');

        this.model.save(attrs, {success: this.onComplete});
      } else {
        new Splash().save({
          comment:  this.comment.comment(),
          track_id: this.model.get('id')
        }, {
          success: this.onComplete
        });
      }
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.comment = new SplashComment({el: this.$('textarea')});

      this.$('[data-widget = "complete-upload"]').hide();

      return this;
    },

    setModel: function(model, mode) {
      var button = this.$('[data-widget = "complete-upload"] input');

      this.model = model;
      this.mode  = mode;

      if (mode == 'edit') {
        this.$('[name = "title"]').val(model.get('title'));
        this.$('[name = "performers"]').val(model.get('performers'));
        this.$('[name = "albums"]').val(model.get('albums'));

        button.val(I18n.t('upload.save'));

        this.$('[data-widget = "metadata"]').show();
      } else {
        button.val(I18n.t('upload.splash'));
      }

      this.$('[data-widget = "complete-upload"]').show();
    },
  });

  window.SuggestedSplashersView = Backbone.View.extend({
    events: {
      'click [data-widget = "next-suggested-users"]': 'viewMore',
      'ignore:splasher': 'load',
      'follow': 'load'
    },
    template: $('#tmpl-suggested-splashers').template(),

    initialize: function() {
      this.page = 1;

      this.collection.bind('reset', this.resetSuggestions, this);
    },

    load: function() {
      this.collection.fetch({data: {page: this.page}});
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.renderSuggestions(this.collection);

      return this;
    },

    renderSuggestions: function(collection) {
      var followerID = this.options.followerID;
      var ul         = this.$('ul');

      collection.each(function(ss) {
        ul.append(new SuggestedSplasherView({
          followerID: followerID,
          model:      ss,
        }).render().el);
      })
    },

    resetSuggestions: function() {
      this.$('li').remove();

      this.renderSuggestions(this.collection);
    },

    viewMore: function() {
      this.page++;

      this.load();
    },
  });

  window.SuggestedSplasherView = Backbone.View.extend({
    events: {
      'click [data-widget = "delete-suggested-user"]': 'ignore'
    },
    tagName: 'li',
    template: $('#tmpl-suggested-splasher').template(),

    initialize: function() {
      this.model.bind('destroy', this.ignored, this);
    },

    ignore: function() {
      this.model.destroy();
    },

    ignored: function() {
      $(this.el).trigger('ignore:splasher');
    },

    render: function() {
      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      this.$('.wrap').append(this.renderRelationship());

      return this;
    },

    renderRelationship: function() {
      var r = new Relationship({
        follower_id: this.options.followerID,
        followed_id: this.model.id,
      });

      return new RelationshipView({
        model:    r,
        refresh:  false,
        tagName:  'span',
        template: $('#tmpl-suggested-relationship').template(),
      }).render().el;
    },
  });

});
