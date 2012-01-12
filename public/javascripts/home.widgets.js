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

      this.metadata.reset();

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

    reset: function() {
      $(this.el).empty();

      this.render();
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
      'ignore:splasher': 'triggerUpdate',
      'follow:splasher': 'triggerUpdate'
    },
    template: $('#tmpl-suggested-splashers').template(),

    initialize: function() {
      this.cursor      = 0;
      this.suggestions = [];
    },

    $ul: function() {
      return this._$ul = this.$('ul');
    },

    advanceCursor: function() {
      this.cursor = this.nextPosition(this.cursor);
    },

    appendSuggestion: function(s) {
      this.$ul().append(s.render().el);
    },

    currentSlice: function() {
      var start = this.cursor;
      var end   = this.nextPosition(start);
      var ms    = this.collection.models;

      if (start < end) {
        return ms.slice(start, end);
      } else {
        var before = ms.slice(start, this.collection.length);
        var after  = ms.slice(0, end);

        return before.concat(after);
      }
    },

    makeSuggestion: function(model) {
      var followerID = this.options.followerID;

      return new SuggestedSplasherView({followerID: followerID, model: model});
    },

    nextPosition: function(cursor) {
      return this.wrappedCursor(cursor + this.options.splashersCount);
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.resetSuggestions();

      return this;
    },

    resetSuggestions: function() {
      _.invoke(this.suggestions, 'remove');

      this.suggestions = _.map(this.currentSlice(), this.makeSuggestion, this);

      _.each(this.suggestions, this.appendSuggestion, this);

      this.suggestionsChanged();
    },

    suggestionsChanged: function() {
      var su = this.$('[data-widget = "next-suggested-users"]');

      if (this.collection.length <= this.options.splashersCount) {
        su.hide();
      } else {
        su.show();
      }
    },

    triggerUpdate: function(e, data) {
      this.collection.remove(data.view.model);

      this.cursor = this.wrappedCursor(this.cursor);

      if (this.collection.length > this.options.splashersCount) {
        var replacement = this.makeSuggestion(_.last(this.currentSlice()));

        this.suggestions.push(replacement);
        this.suggestions.splice(this.suggestions.indexOf(data.view), 1);

        this.appendSuggestion(replacement);
      }

      this.suggestionsChanged();

      data.view.model.destroy();
      data.view.remove(true);
    },

    viewMore: function(e) {
      e.preventDefault();

      this.advanceCursor();

      this.resetSuggestions();
    },

    wrappedCursor: function(cursor) {
      if (cursor >= this.collection.length) {
        return cursor - this.collection.length;
      } else {
        return cursor;
      }
    },
  });

  window.SuggestedSplasherView = Backbone.View.extend({
    events: {
      'click [data-widget = "delete-suggested-user"]': 'triggerIgnore',
      'follow': 'triggerFollow',
    },
    tagName: 'li',
    template: $('#tmpl-suggested-splasher').template(),

    initialize: function() {
      _.bindAll(this, 'remove');
    },

    remove: function(animate) {
      var self = this;

      if (animate) {
        $(this.el).animate({height: 0}, {
          duration: 500,
          complete: this.remove
        });

        return this;
      } else {
        return Backbone.View.prototype.remove.call(this);
      }
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

    triggerFollow: function(e) {
      e.preventDefault();

      $(this.el).trigger('follow:splasher', {view: this})
    },

    triggerIgnore: function(e) {
      e.preventDefault();

      $(this.el).trigger('ignore:splasher', {view: this})
    },
  });

  window.InviteUserView = Backbone.View.extend({
    events:       {
      'ajax:success': 'reload',
      'ajax:error': 'error',
      'focus  [data-widget = "email"]' : "clearText",
    },

    template: $('#tmpl-email-invitation').template(),

    error: function() {
      this.$("[data-widget = 'email']").addClass('error');
    },

    render: function() {
      $(this.el).html($.tmpl(this.template, {invitations_count: this.options.remaining_invitations}));

      return this;
    },

    reload: function(_, data) {
      $("[data-widget = 'remaining_count']").html(data.remaining_count);
      $("[data-widget = 'email']").val('');
      this.$("[data-widget = 'email']").removeClass('error');

      if (data.remaining_count < 1) {
        this.$('input').attr('disabled', true);
      }
    },

    clearText: function(){
      this.$("[data-widget = 'email']").val('');
    },
  });

  window.Tutorial = Backbone.View.extend({
    initialize: function() {
      this.$content = this.$('.tutorial-content');
    },

    center: function() {
      var $el  = $(this.el);
      var $w   = $(window);
      var top  = ($w.height() - $el.outerHeight()) / 2 + $w.scrollTop() + "px";
      var left = ($w.width() - $el.outerWidth()) / 2 + $w.scrollLeft() + "px";

      $el.css("position","absolute");
      $el.css("top", top);
      $el.css("left", left);
    },

    render: function() {
      this.setupSlideShow();
      this.center();
      this.show();

      return this;
    },

    setupSlideShow: function() {
      this.$content.cycle({
        fx: 'scrollLeft',
        pager: this.$('.tutorial-pager-absolute'),
      });
    },

    show: function() {
      $(this.el).show();
    },
  });
});
