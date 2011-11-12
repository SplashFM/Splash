$(function() {
  window.Home = Backbone.View.extend({
    initialize: function(opts) {
      this.trackSearch = new TrackSearch(opts.search)
      this.feed        = new Events(opts.events);
    },
  });

  TrackSearch = Search.extend({
    collection: new TrackList,
    el: '[data-widget = "track-search"]',
    events: _.extend({
      'click [data-widget = "toggle-upload"]': 'showUpload'
    }, Search.prototype.events),
    menuContainer: 'ul',

    initialize: function() {
      Search.prototype.initialize.call(this);

      this.upload = new Home.Upload().render();
      this.$('.wrap').append(this.upload.hide().el);
    },

    open: function() {
      this.menu.find('li:last').addClass('last');
    },

    renderItem: function(i) {
      var opts = {model: i};

      $(new TrackSearch.Track(opts).render().el).appendTo(this.menu);
    },

    showUpload: function() {
      this.upload.show();
    },
  });

  TrackSearch.Track = Backbone.View.extend({
    tagName: 'li',
    template: $('#tmpl-home-track').template(),

    render: function() {
      $(this.el).attr('data-track_id', this.model.get('id'));
      $(this.el).html($.tmpl(this.template, this.model.toJSON()).html());

      new TrackSearch.Track.FullSplashAction({
        model: this.model,
        el: $('[data-widget = "full-splash-action"]', this.el),
      });

      return this;
    },
  });

  TrackSearch.Track.FullSplashAction = BaseApp.SplashAction.extend({
    events: {
      'click a': 'toggle',
      'submit form': 'splash'
    },

    splash: function(e) {
      e.preventDefault();

      new Splash().save({
        comment:  this.$('form textarea').val(),
        track_id: this.model.get('id')
      }, {
        success: this.broadcastSplash
      });
    },

    toggle: function() {
      this.$('form').toggle();
    },
  });

  window.Home.Upload = Backbone.View.extend({
    className: 'uploadForm',
    events: {'upload:complete': 'hide'},
    tagName: 'div',
    template: $('#tmpl-upload').template(),

    initialize: function() {
      _.bindAll(this, 'hide', 'onUpload');
    },

    hide: function() {
      $(this.el).hide();
    },

    hide: function() {
      $(this.el).hide();

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

      this.metadata = new Home.Upload.Metadata({model: this.model});

      $(this.el).append(this.metadata.render().el);

      return this;
    },

    show: function() {
      $(this.el).show();

      return this;
    },
  });

  window.Home.Upload.Metadata = Backbone.View.extend({
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