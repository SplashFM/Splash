$(function() {
  window.Home = Backbone.View.extend({
    initialize: function(opts) {
      this.trackSearch = new Home.TrackSearch(opts.search)
      this.feed        = new Events(opts.events);
      this.app         = opts.app;

      this.app.bind('endlessScroll', this.feed.scroll, this)
    },
  });

  Home.TrackSearch = Search.extend({
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

      $(new Home.TrackSearch.Track(opts).render().el).appendTo(this.menu);
    },

    showUpload: function() {
      this.upload.show();
    },
  });

  Home.TrackSearch.Track = Backbone.View.extend({
    tagName: 'li',
    template: $('#tmpl-home-track').template(),

    render: function() {
      $(this.el).attr('data-track_id', this.model.get('id'));
      $(this.el).html($.tmpl(this.template, this.model.toJSON()).html());

      new Home.TrackSearch.Track.FullSplashAction({
        model: this.model,
        el: $('[data-widget = "full-splash-action"]', this.el),
      });

      return this;
    },
  });

  Home.TrackSearch.Track.FullSplashAction = BaseApp.SplashAction.extend({
    events: {
      'click a': 'toggle',
      'submit form': 'splash'
    },

    splash: function() {
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
    tagName: 'div',
    template: $('#tmpl-upload').template(),

    initialize: function() {
      _.bindAll(this, 'onUpload');
    },

    hide: function() {
      $(this.el).hide();

      return this;
    },

    onUpload: function(_, data) {
      this.metadata.setModel(new Track(data.result));
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
    tagName: 'div',
    template: $('#tmpl-upload-metadata').template(),

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },

    setModel: function(model) {
      this.model = model;

      this.$('[name = "title"]').val(model.get('title'));
      this.$('[name = "performers"]').val(model.get('performers'));

      this.$('[data-widget = "metadata"]').show();
    },
  });
});