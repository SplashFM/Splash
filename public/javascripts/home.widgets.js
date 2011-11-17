$(function() {
  TrackSearch = Search.extend({
    collection: new TrackList,
    el: '[data-widget = "track-search"]',
    events: _.extend({
      'click [data-widget = "toggle-upload"]': 'showUpload'
    }, Search.prototype.events),
    menuContainer: 'ul',

    initialize: function() {
      Search.prototype.initialize.call(this);
      this.upload = new Upload().render();
      this.upload.bind('hiding',this.removeUploadProgressForm);
      this.$('.wrap').append(this.upload.hide().el);
    },

    open: function() {
      this.menu.find('li:last').addClass('last');
    },

    renderItem: function(i) {
      var opts = {model: i};

      $(new TrackSearch.Track(opts).render().el).appendTo(this.menu);
    },
    prepareUploadProgressForm: function() {
      var upload_bar = $(this.el).parents('.container').find('input.field');
      upload_bar.addClass('uploading')
      upload_bar.attr('disabled','true');
      upload_bar.attr('value','Uploading');
    },
    removeUploadProgressForm: function() {
      var upload_bar = $(this.el).parents('.container').find('input.field');
      upload_bar.removeClass('uploading')
      upload_bar.removeAttr('disabled','disabled');
      upload_bar.attr('value','');
    },
    showUpload: function(e) {
      this.prepareUploadProgressForm();
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

      this.mentions = new UserMentions({el: this.$('form textarea'),
                                        parent: this.el});
    },

    splash: function(e) {
      e.preventDefault();

      new Splash().save({
        comment:  this.mentions.commentWithMentions(),
        track_id: this.model.get('id')
      }, {
        success: this.broadcastSplash
      });
    },

    toggle: function() {
      this.$('form').toggle();
    },
  });

  Upload = Backbone.View.extend({
    className: 'uploadForm',
    events: {'upload:complete': 'hide'},
    tagName: 'div',
    template: $('#tmpl-upload').template(),

    initialize: function() {
      _.bindAll(this, 'hide', 'onUpload');
      _this = this;
      $(this.el).clickout(function(){_this.hide("tripped")});
    },

    hide: function(args) {
      $(this.el).hide();
      this.mentions.reset();
      if(args) {
        this.trigger("hiding");
      }

      return this;
    },

    onUpload: function(_, data) {
      this.metadata.setModel(new UndiscoveredTrack(data.result));
    },

    render: function() {
      $(this.el).append($.tmpl(this.template));

      this.$('form').fileupload({
        start: function() { console.log("Uploading."); },
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